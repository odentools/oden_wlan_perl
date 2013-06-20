/**
	Gnome-shell extension for OdenWlan perl
	https://github.com/odentools/oden_wlan_perl
**/

const St = imports.gi.St;
const Main = imports.ui.main;
const Lang = imports.lang;
const Shell = imports.gi.Shell;
const Tweener = imports.ui.tweener;
const PopupMenu = imports.ui.popupMenu;
const Util = imports.misc.util;
const GLib = imports.gi.GLib;

let item, menu;

function _NetworkReset() {
	Util.spawnCommandLine('gnome-terminal --title="OdenWlan perl" -e '+ ("sudo -s odenwlan").quote());
}

function init() {
	menu = Main.panel._statusArea.network.menu;
}

function enable() {
	item = new PopupMenu.PopupMenuItem(_("Run OdenWlan"));
	item.connect('activate', Lang.bind(item, _NetworkReset));
	menu.addMenuItem(item, menu.numMenuItems - 1);
}

function disable() {
    if (item != null){
    	item.destroy();
    }
}