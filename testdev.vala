/* ex:ts=4:sw=4:sts=4:et */
/**
 * Copyright (C) 2015 Maciej Borzecki <maciek.borzecki@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

using GUPnP;
using Soup;
using Xml;

const string DEVICE_FILE = "device.xml";
const string DEVICE_DIR = ".";

/**
 * config_cb:
 *
 * Callback for presentation URL handling
 */
private static void config_cb(Soup.Server server, Soup.Message msg,
							  string path) {

	message("handle config request");

	string response = """Hello!

This is an example response. You might want to redirect the client
to anoter location or implement a nice web page right here.
""";

	msg.set_response("text/plain", Soup.MemoryUse.COPY,
					 response.data);
	msg.set_status(Soup.Status.OK);
}

/**
 * find_presentation_url:
 * @file: path to device XML file
 *
 * Parse device XML file and locate presentation URL.
 */
private string find_presentation_url(string file) {

	// ugly libxml bindings

	Xml.Doc *doc = Xml.Parser.parse_file(file);
	if (doc == null) {
		error("failed to parse %s", file);
	}

	Xml.XPath.Context ctx = new Xml.XPath.Context(doc);
	// register namespace
	ctx.register_ns("ud", "urn:schemas-upnp-org:device-1-0");

	Xml.XPath.Object *res;
	res = ctx.eval_expression("/ud:root/ud:device/ud:presentationURL");

	// expecting a nodeset with single node
	if (res == null || res->type != Xml.XPath.ObjectType.NODESET
		|| res->nodesetval->length() != 1) {
		message("res type: %d", res->type);
		error("failed to find presentation URL");
	}

	Xml.Node *node = res->nodesetval->item(0);
	// node content is the presentation URL
	message("node content: %s", node->get_content());

	string url = node->get_content();

	delete res;
	delete doc;

	return url;
}

public static int main(string[] args)
{
	Context ctx = null;

	try {
		ctx = new GUPnP.Context(null, null, 0);
	} catch (GLib.Error e) {
		error("failed to create context: %s", e.message);
	}

	var rootdev = new GUPnP.RootDevice(ctx, DEVICE_FILE, DEVICE_DIR);

	var url = find_presentation_url(Path.build_filename(DEVICE_DIR,
														DEVICE_FILE));
	if (url != null) {
		message("found presentation URL: %s", url);

		ctx.add_server_handler(false, url,
							   (server, msg, path, query, client) => {
								   message("got config request");
								   config_cb(server, msg, path);
							   });
	} else {
		message("no presentation URL found");
	}

	rootdev.set_available(true);

	message("location address: http://%s:%u", ctx.host_ip, ctx.port);
	var loop = new MainLoop();

	message("loop run()...");
	loop.run();
	message("loop done..");
	return 0;
}