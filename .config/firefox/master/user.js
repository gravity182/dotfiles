/** PRIVACY ***/

/** TRACKING PROTECTION ***/
user_pref("browser.contentblocking.category", "standard");

/** MOZILLA PERMISSIONS ***/
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);

/** CRASH REPORTS ***/
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

/** TELEMETRY ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

/** UI ***/

/** MOZILLA UI ***/
user_pref("browser.urlbar.autocomplete.enabled", true);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("media.hardwaremediakeys.enabled", true);
user_pref("dom.media.mediasession.enabled", true);
user_pref("browser.tabs.firefox-view", false);

// works only with default theme
// I use the dark scheme anyway, so this won't work
// https://github.com/zvuc/firefox-macos-native-tabbar?tab=readme-ov-file
user_pref("widget.macos.titlebar-blend-mode.behind-window", true);
user_pref("browser.theme.native-theme", true);

// PREF: preferred color scheme for websites and sub-pages
// Dark (0), Light (1), System (2), Browser (3)
user_pref("layout.css.prefers-color-scheme.content-override", 0);
// see https://superuser.com/a/1623999
user_pref("layout.word_select.eat_space_to_next_word", false);

// don't start find when pressing a character
// that is, find is only activated explicitly via ctrl-f
user_pref("accessibility.typeaheadfind", false);
// prefill the search box with the selected word
user_pref("accessibility.typeaheadfind.prefillwithselection", true);
user_pref("accessibility.typeaheadfind.flashBar", 0);
// highlight all matches
user_pref("findbar.highlightAll", true);

// disable Pocket
user_pref("extensions.pocket.enabled", false);
user_pref(
  "browser.newtabpage.activity-stream.section.highlights.includePocket",
  false,
);

// enable Picture-in-Pucture (PiP)
user_pref(
  "extensions.pictureinpicture.enable_picture_in_picture_overrides",
  true,
);
user_pref(
  "media.videocontrols.picture-in-picture.respect-disablePictureInPicture",
  true,
);

// disable Reader
user_pref("reader.parse-on-load.enabled", false);
user_pref("narrate.enabled", false);

// enable Screenshots
user_pref("extensions.screenshots.disabled", false);

user_pref("media.autoplay.blocking_policy", 0);
user_pref("browser.search.separatePrivateDefault.ui.enabled", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("print.prefer_system_dialog", false);
user_pref("dom.disable_beforeunload", false);

// Tab behaviour
user_pref("browser.tabs.warnOnClose", true);
user_pref("browser.tabs.tabmanager.enabled", false);
// bookmarks will be opened in a new tab only via the middle mouse click
user_pref("browser.tabs.loadBookmarksInTabs", false);
// don't switch to a opened bookmark immediately
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.tabs.firefox-view", false);
user_pref("browser.tabs.hoverPreview.enabled", false);
// default min tab width is 76
user_pref("browser.tabs.tabMinWidth", 76);

// enable chrome/userChrome.css
// read https://www.reddit.com/r/firefox/wiki/userchrome
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

/** SCROLLING */
// based on the 'OPTION: SMOOTH SCROLLING' from https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
// if you have a 120+ Hz display, use the 'OPTION: NATURAL SMOOTH SCROLLING V3 [MODIFIED]'
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
// this settings was set at 250 in Betterfox, but it made touchpad scrolling too fast
// I like the default value of 100, so just set it explicitly
user_pref("mousewheel.default.delta_multiplier_y", 100); // Adjust this settings to your liking
// msdPhysics makes scrolling much more pleasant
user_pref("general.smoothScroll.msdPhysics.enabled", true); // default is false

/** AI Features */
user_pref("browser.ml.enable", false); // machine learning features in Firefox
user_pref("browser.ml.chat.enabled", false); // AI Chatbot (https://docs.openwebui.com/tutorials/integrations/firefox-sidebar/#additional-about-settings)
user_pref("browser.ml.chat.menu", false); // "Ask a chatbot" in tab context menu
user_pref("browser.ml.chat.shortcuts", false); // "Enable custom shortcuts for the AI chatbot sidebar"
user_pref("browser.ml.chat.shortcuts.custom", false);
user_pref("extensions.ml.enabled", false); // might only be relevant for app developers
user_pref("browser.ml.linkPreview.enabled", false);
user_pref("browser.tabs.groups.smart.enabled", false); // "Use AI to suggest tabs and a name for tab groups" in settings
user_pref("browser.tabs.groups.smart.userEnabled", false);
