# gupnp-test

A test implementation of a UPnP device. Uses a trimmed down version of
_2.1 Device Description_ from _UPnP Device Architecture v1.0_ document.

The device provides no services, but a single presentation URL. Once
the presentation URL is accessed by a HTTP client, a nice 'Hello'
message will be shown.

## Redirect to another location

A real life use case, when the UPnP advertisment daemon does not
handle the presentation. Since the URL included in `device.xml` is
relative, the client will attempt to access it using the `Location`
header found in SSDP messages. An example message broadcast by GUPnP
looks like this:

    NOTIFY * HTTP/1.1
    Host: 239.255.255.250:1900
    Cache-Control: max-age=1800
    Location: http://192.168.1.136:55016/1a6c9157-162a-4787-b5cf-4b91be2cc454.xml
    Server: Linux/3.19.2-1-ARCH UPnP/1.0 GUPnP/0.20.13
    NTS: ssdp:alive
    NT: upnp:rootdevice
    USN: uuid:1a6c9157-162a-4787-b5cf-4b91be2cc454::upnp:rootdevice

When a client performs **GET** request to
http://192.168.1.136:55016/config a redirect to a predefined URL
(hardcoded in `_handle_config` callback - check the code) will be
made.
