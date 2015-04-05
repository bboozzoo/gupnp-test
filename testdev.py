#!/usr/bin/python2
# Copyright (C) 2015 Maciej Borzecki <maciek.borzecki@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
"""A demo program implementing a use case in which control points can
discover a simple service-less device. In this case the device
provides only presentation URL that the contron point can provide to
the user for accessing via a web browser. The device UPnP interface
does not provide the presentation URL directl but rather redirects the
HTTP query to a different URL.
"""



from gi.repository import GUPnP, GLib, Soup
import xml.etree.ElementTree as xmlet
import logging
import os.path

GLib.threads_init()

DEVICE_FILE = 'device.xml'
DEVICE_DIR = os.path.dirname(__file__)
# target url

def _handle_config(server, message, path, query, client, user_param):
    """Callback handler to presentation"""

    logging.debug('handle URI: %s', path)
    logging.debug('address: %s', message.get_address().get_name())

    # use the code below to redirect the client to a different
    # location, but still within the same host

    # Example: redirect to the same location, but port 80, /someurl

    # address = message.get_address().get_name()
    # redirect_url = 'http://{address}/someurl'.format(address=address)
    # message.set_redirect(Soup.Status.FOUND, redirect_url)

    # Or just print out a nice response
    response = """Hello!

This is an example response. You might want to redirect the client
to anoter location or implement a nice web page right here.
    """

    message.set_response("text/plain",
                         Soup.MemoryUse.COPY,
                         response)
    message.set_status(Soup.Status.OK)


def _find_presentation_url(device_xml):
    """Find a presentation URL inside device xml file """
    root = xmlet.parse(device_xml).getroot()

    # setup upnp device namespace handling
    ns = {'ud': 'urn:schemas-upnp-org:device-1-0'}

    url = root.find('ud:device/ud:presentationURL', ns).text
    logging.debug('%s config URL: %s', device_xml, url)

    return url


def main():
    loop = GLib.MainLoop()

    logging.debug('create context...')
    ctx = GUPnP.Context.new(None, None, 0)

    device_xml =  os.path.join(DEVICE_DIR, DEVICE_FILE)
    logging.debug('load device from %s', device_xml)

    rd = GUPnP.RootDevice.new(ctx, DEVICE_FILE, DEVICE_DIR)

    presentation_url = _find_presentation_url(device_xml)
    # add handler for presentation URL
    ctx.add_server_handler(False, presentation_url,
                           _handle_config, None)
    # advertise the device
    rd.set_available(True)

    logging.debug('location address http://%s:%d',
                  ctx.props.host_ip, ctx.props.port)

    logging.debug('loop run()..')
    loop.run()
    logging.debug('loop done..')


if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    main()
