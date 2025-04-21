#include <X11/XF86keysym.h>

/* ====== Appearance ====== */
static const unsigned int borderpx  = 2;        /* Border pixel width */
static const unsigned int snap     = 32;       /* Snap pixel */
static const unsigned int gappih   = 10;       /* Horizontal inner gap */
static const unsigned int gappiv   = 10;       /* Vertical inner gap */
static const unsigned int gappoh   = 10;       /* Horizontal outer gap */
static const unsigned int gappov   = 10;       /* Vertical outer gap */
static const int smartgaps         = 0;        /* Disable smart gaps */
static const int showbar           = 1;        /* Show bar */
static const int topbar            = 1;        /* Top bar */

/* Fonts */
static const char *fonts[] = { "SauceCodeProNerdFontMono:size=10" };
static const char dmenufont[] = "SauceCodeProNerdFontMono:size=10";

/* Colors */
static const char col_black[]   = "#141414";
static const char col_white[]   = "#c7c7c7";
static const char col_magenta[] = "#f691ee";
static const char col_cyan[]    = "#78e8c6";
static const char col_green[]   = "#a9dc76";
static const char col_red[]     = "#fc6a67";

static const char *colors[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = { col_white, col_black, col_white },
    [SchemeSel]  = { col_black, col_magenta, col_magenta },
};

/* ====== Tags and Layouts ====== */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* Window rules */
static const Rule rules[] = {
    /* class      instance    title       tags mask  isfloating  monitor */
    { "Gimp",     NULL,       NULL,       0,         1,          -1 },
    { "Firefox",  NULL,       NULL,       1 << 8,    0,          -1 },
};

/* Layout settings */
static const float mfact     = 0.55;  /* Master area size factor */
static const int nmaster     = 1;     /* Number of clients in master area */
static const int resizehints = 0;     /* Disable size hints */
static const int lockfullscreen = 1;   /* Force focus on fullscreen */

#define FORCE_VSPLIT 1  /* Force vertical split in nrowgrid */
#include "vanitygaps.c"

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* Default */
    { "[M]",      monocle },
    { "[@]",      spiral },
    { "[\\]",     dwindle },
    { "H[]",      deck },
    { "TTT",      bstack },
    { "===",      bstackhoriz },
    { "HHH",      grid },
    { "###",      nrowgrid },
    { "---",      horizgrid },
    { ":::",      gaplessgrid },
    { "|M|",      centeredmaster },
    { ">M>",      centeredfloatingmaster },
    { "><>",      NULL },    /* Floating */
    { NULL,       NULL },
};

/* ====== Key Definitions ====== */
#define MODKEY Mod4Mask  /* Super/Windows key */
#define TAGKEYS(KEY,TAG) \
    { MODKEY,            KEY, view,      {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,KEY, toggleview,{.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,  KEY, tag,       {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY, toggletag, {.ui = 1 << TAG} },

/* Command shortcuts */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/zsh", "-c", cmd, NULL } }

/* Application commands */
static const char *flamcmd[] = { "/home/trigger/.local/scripts/flame.sh", NULL };
static char dmenumon[2] = "0";
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, NULL };
static const char *roficmd[] = { "rofi", "-show", "drun", "-no-lazy-grab", NULL };
static const char *termcmd[] = { "st", NULL };

/* Media controls */
static const char *mutecmd[] = { "pactl", "set-sink-mute", "0", "toggle", NULL };
static const char *volupcmd[] = { "pactl", "set-sink-volume", "0", "+5%", NULL };
static const char *voldowncmd[] = { "pactl", "set-sink-volume", "0", "-5%", NULL };

/* Brightness controls */
static const char *brupcmd[] = { "sudo", "light", "-A", "5", NULL };
static const char *brdowncmd[] = { "sudo", "light", "-U", "5", NULL };

/* Key bindings */
static const Key keys[] = {
    /* modifier            key            function        argument */
    /* Applications */
    { MODKEY,              XK_d,          spawn,         {.v = roficmd } },
    { MODKEY,              XK_Return,     spawn,         {.v = termcmd } },
    { 0,                   XK_Print,      spawn,         {.v = flamcmd } },
    
    /* Window management */
    { MODKEY,              XK_b,          togglebar,     {0} },
    { MODKEY,              XK_f,          zoom,          {0} },
    { MODKEY,              XK_q,          killclient,    {0} },
    { MODKEY,              XK_Tab,        view,          {0} },
    { MODKEY|ShiftMask,    XK_space,      togglefloating,{0} },
    { MODKEY,              XK_space,      setlayout,     {0} },
    
    /* Navigation */
    { MODKEY,              XK_Right,      focusstack,    {.i = +1 } },
    { MODKEY,              XK_Left,       focusstack,    {.i = -1 } },
    { MODKEY,              XK_comma,      focusmon,      {.i = -1 } },
    { MODKEY,              XK_period,     focusmon,      {.i = +1 } },
    { MODKEY|ShiftMask,    XK_comma,      tagmon,        {.i = -1 } },
    { MODKEY|ShiftMask,    XK_period,     tagmon,        {.i = +1 } },
    
    /* Layout adjustment */
    { MODKEY,              XK_Up,         setmfact,      {.f = +0.05} },
    { MODKEY,              XK_Down,       setmfact,      {.f = -0.05} },
    { MODKEY|ShiftMask,    XK_Up,         setcfact,      {.f = -0.25} },
    { MODKEY|ShiftMask,    XK_Down,       setcfact,      {.f = +0.25} },
    { MODKEY|ShiftMask,    XK_o,          setcfact,      {.f =  0.00} },
    
    /* Gaps */
    { MODKEY|Mod1Mask,     XK_equal,      incrgaps,      {.i = +1 } },
    { MODKEY|Mod1Mask|ShiftMask, XK_minus,incrgaps,      {.i = -1 } },
    { MODKEY|Mod1Mask,     XK_0,          togglegaps,    {0} },
    
    /* Media keys */
    { 0,                   XF86XK_AudioMute,          spawn, {.v = mutecmd } },
    { 0,                   XF86XK_AudioLowerVolume,    spawn, {.v = voldowncmd } },
    { 0,                   XF86XK_AudioRaiseVolume,    spawn, {.v = volupcmd } },
    { 0,                   XF86XK_MonBrightnessUp,     spawn, {.v = brupcmd } },
    { 0,                   XF86XK_MonBrightnessDown,   spawn, {.v = brdowncmd } },
    
    /* Tags */
    { MODKEY,              XK_0,          view,         {.ui = ~0 } },
    { MODKEY|ShiftMask,    XK_0,          tag,          {.ui = ~0 } },
    TAGKEYS(               XK_1,                        0)
    TAGKEYS(               XK_2,                        1)
    TAGKEYS(               XK_3,                        2)
    TAGKEYS(               XK_4,                        3)
    TAGKEYS(               XK_5,                        4)
    TAGKEYS(               XK_6,                        5)
    TAGKEYS(               XK_7,                        6)
    TAGKEYS(               XK_8,                        7)
    TAGKEYS(               XK_9,                        8)
    
    /* System */
    { MODKEY|ShiftMask,    XK_q,          quit,         {0} },
};

/* ====== Mouse Bindings ====== */
static const Button buttons[] = {
    /* click                event mask      button    function        argument */
    { ClkLtSymbol,          0,             Button1,  setlayout,      {0} },
    { ClkLtSymbol,          0,             Button3,  setlayout,      {.v = &layouts[2]} },
    { ClkWinTitle,          0,             Button2,  zoom,           {0} },
    { ClkStatusText,        0,             Button2,  spawn,          {.v = termcmd } },
    { ClkClientWin,         MODKEY,        Button1,  movemouse,      {0} },
    { ClkClientWin,         MODKEY,        Button2,  togglefloating, {0} },
    { ClkClientWin,         MODKEY,        Button3,  resizemouse,    {0} },
    { ClkTagBar,            0,             Button1,  view,           {0} },
    { ClkTagBar,            0,             Button3,  toggleview,     {0} },
    { ClkTagBar,            MODKEY,        Button1,  tag,            {0} },
    { ClkTagBar,            MODKEY,        Button3,  toggletag,      {0} },
};
