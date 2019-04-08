
AIOpts = {
    {
        default = 1,
        label = "<LOC aisettings_0187>AI Unit Cap",
        help = "<LOC aisettings_0188>Set an AI unit cap independently from player unit cap.",
        key = 'AIUnitCap',
        value_text = "%s",
        value_help = "<LOC aisettings_0189>%s units per AI may be in play",
        values = {
            {
                text = "<LOC aisettings_0190>Same as Player Cap",
                help = "<LOC aisettings_0191>AI uses player unit cap.",
                key = '0',
            },
            '125', '150', '175', '200', '250', '300', '350', '400', '450', '500', '600', '700', '800', '900',
            '1000', '1100', '1200', '1300', '1400', '1500', '1600', '1700', '1800', '1900', '2000'
        },
    },
    {
        default = 2,
        label = "<LOC aisettings_0192>AI Map Marker generator",
        help = "<LOC aisettings_0193>Autogenerate map markers for AI pathfinding on 5x5 and 10x10 maps",
        key = 'AIMapMarker',
        values = {
            {
                text = "<LOC aisettings_0194>Original Map markers",
                help = "<LOC aisettings_0195>Use map markers done by the mapauthor",
                key = 'map',
            },
            {
                text = "<LOC aisettings_0196>Autogenerate when needed",
                help = "<LOC aisettings_0197>Autogenerate map markers if no original markers are present",
                key = 'miss',
            },
            {
                text = "<LOC aisettings_0198>Autogenerate Always",
                help = "<LOC aisettings_0199>Autogenerate map markers always (ignore original markers if present)",
                key = 'all',
            },
            {
                text = "<LOC aisettings_0200>No Marker",
                help = "<LOC aisettings_0201>Use the c-engine to path the way (20%% slower)",
                key = 'off',
            },
            {
                text = "<LOC aisettings_0202>Print to game.log",
                help = "<LOC aisettings_0203>Print the marker masterchain to the game.log for copy&paste",
                key = 'print',
            },
        },
    },
    {
        default = 1,
        label = "<LOC aisettings_0153>DEBUG: AI pathfinding",
        help = "<LOC aisettings_0154>Displays pathfinding, waypoints and location radii (only AI-Uveso)",
        key = 'AIPathingDebug',
        values = {
            {
                text = "<LOC aisettings_0155>Off",
                help = "<LOC aisettings_0156>Display is off",
                key = 'off',
            },
            {
                text = "<LOC aisettings_0185>Pathfinding",
                help = "<LOC aisettings_0186>Show pathfinding for all layers",
                key = 'path',
            },
            {
                text = "<LOC aisettings_0157>Pathfinding and locations",
                help = "<LOC aisettings_0158>Show pathfinding and location radii",
                key = 'all',
            },
            {
                text = "<LOC aisettings_0159>Path and land marker",
                help = "<LOC aisettings_0160>Show pathfinding, land waypoints and paths",
                key = 'land',
            },
            {
                text = "<LOC aisettings_0161>Path and water marker",
                help = "<LOC aisettings_0162>Show pathfinding, water waypoints and paths",
                key = 'water',
            },
            {
                text = "<LOC aisettings_0163>Path and amphibious marker",
                help = "<LOC aisettings_0164>Show pathfinding, amphibious waypoints and paths",
                key = 'amph',
            },
            {
                text = "<LOC aisettings_0165>Path and air marker",
                help = "<LOC aisettings_0166>Show pathfinding, air waypoints and paths",
                key = 'air',
            },
        },
    },
    {
        default = 1,
        label = "<LOC aisettings_0167>DEBUG: AI Platoon names",
        help = "<LOC aisettings_0168>Displays Platoon and AI plan name",
        key = 'AIPLatoonNameDebug',
        values = {
            {
                text = "<LOC aisettings_0155>Off",
                help = "<LOC aisettings_0169>Display is off",
                key = 'off',
            },
            {
                text = "<LOC aisettings_0170>AI Uveso names",
                help = "<LOC aisettings_0171>Show platoon and AI plan name for AI Uveso",
                key = 'Uveso',
            },
            {
                text = "<LOC aisettings_0172>AI Dilli names",
                help = "<LOC aisettings_0173>Show platoon and AI plan name for AI Dilli",
                key = 'Dilli',
            },
            {
                text = "<LOC aisettings_0174>AI Sorian names",
                help = "<LOC aisettings_0175>Show platoon and AI plan name for AI Sorian",
                key = 'Sorian',
            },
            {
                text = "<LOC aisettings_0176>All AI's",
                help = "<LOC aisettings_0177>Show platoon and AI plan name for all AI's",
                key = 'all',
            },
        },
    },
    {
        default = 1,
        label = "<LOC aisettings_0178>DEBUG: AI BuilderManager",
        help = "<LOC aisettings_0179>Print platoon builder names into the game.log",
        key = 'AIBuilderNameDebug',
        values = {
            {
                text = "<LOC aisettings_0155>Off",
                help = "<LOC aisettings_0180>Logging is off",
                key = 'off',
            },
            {
                text = "<LOC aisettings_0170>AI Uveso names",
                help = "<LOC aisettings_0181>Log builder for AI Uveso",
                key = 'Uveso',
            },
            {
                text = "<LOC aisettings_0172>AI Dilli names",
                help = "<LOC aisettings_0182>Log builder for AI Dilli",
                key = 'Dilli',
            },
            {
                text = "<LOC aisettings_0174>AI Sorian names",
                help = "<LOC aisettings_0183>Log builder for AI Sorian",
                key = 'Sorian',
            },
            {
                text = "<LOC aisettings_0176>All AI's",
                help = "<LOC aisettings_0184>Log builder for all AI's",
                key = 'all',
            },
        },
   },
}
