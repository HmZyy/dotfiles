
// Production
#r "C:\Program Files\workspacer\workspacer.Shared.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.Gap\workspacer.Gap.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"

using System;
using System.Collections.Generic;
using System.Linq;
using workspacer;
using workspacer.Bar;
using workspacer.Bar.Widgets;
using workspacer.Gap;
using workspacer.ActionMenu;
using workspacer.FocusIndicator;

return new Action<IConfigContext>((IConfigContext context) =>
{
    /* Variables */
    var fontSize = 9;
    var barHeight = 19;
    var fontName = "Cascadia Code PL";
    var background = new Color(0x0, 0x0, 0x0);

    /* Config */
    context.CanMinimizeWindows = true;

    /* Gap */
    var gap = barHeight - 8;
    var gapPlugin = context.AddGap(new GapPluginConfig() { InnerGap = gap, OuterGap = gap / 2, Delta = gap / 2 });

    /* Bar */
    context.AddBar(new BarPluginConfig()
    {
        FontSize = fontSize,
        BarHeight = barHeight,
        FontName = fontName,
        DefaultWidgetBackground = background,
        LeftWidgets = () => new IBarWidget[]
        {
            new WorkspaceWidget(), new TextWidget(": "), new TitleWidget() {
                IsShortTitle = true
            }
        },
        RightWidgets = () => new IBarWidget[]
        {
            new BatteryWidget(),
            new TimeWidget(1000, "HH:mm:ss dd-MMM-yyyy"),
            new ActiveLayoutWidget(),
        }
    });

    /* Bar focus indicator */
    context.AddFocusIndicator();

    /* Default layouts */
    Func<ILayoutEngine[]> defaultLayouts = () => new ILayoutEngine[]
    {
        new TallLayoutEngine(),
        new VertLayoutEngine(),
        new HorzLayoutEngine(),
        new FullLayoutEngine(),
    };

    context.DefaultLayouts = defaultLayouts;

    /* Workspaces */
    // Array of workspace names and their layouts
    (string, ILayoutEngine[])[] workspaces =
    {
        ("1", defaultLayouts()),
        ("2", new ILayoutEngine[] { new HorzLayoutEngine(), new TallLayoutEngine() }),
        ("3", defaultLayouts()),
        ("4", defaultLayouts()),
        ("5", defaultLayouts()),
        ("6", defaultLayouts()),
    };

    foreach ((string name, ILayoutEngine[] layouts) in workspaces)
    {
        context.WorkspaceContainer.CreateWorkspace(name, layouts);
    }

    /* Filters */
    context.WindowRouter.AddFilter((window) => !window.ProcessFileName.Equals("1Password.exe"));
    context.WindowRouter.AddFilter((window) => !window.ProcessFileName.Equals("pinentry.exe"));

    // The following filter means that Edge will now open on the correct display
    context.WindowRouter.AddFilter((window) => !window.Class.Equals("ShellTrayWnd"));

    /* Routes */
    context.WindowRouter.RouteProcessName("Discord", "6");
    context.WindowRouter.RouteProcessName("Spotify", "6");

    /* Action menu */
    var actionMenu = context.AddActionMenu(new ActionMenuPluginConfig()
    {
        RegisterKeybind = false,
        MenuHeight = barHeight,
        FontSize = fontSize,
        FontName = fontName,
        Background = background,
    });

    /* Action menu builder */
    Func<ActionMenuItemBuilder> createActionMenuBuilder = () =>
    {
        var menuBuilder = actionMenu.Create();

        // Switch to workspace
        menuBuilder.AddMenu("switch", () =>
        {
            var workspaceMenu = actionMenu.Create();
            var monitor = context.MonitorContainer.FocusedMonitor;
            var workspaces = context.WorkspaceContainer.GetWorkspaces(monitor);

            Func<int, Action> createChildMenu = (workspaceIndex) => () =>
            {
                context.Workspaces.SwitchMonitorToWorkspace(monitor.Index, workspaceIndex);
            };

            int workspaceIndex = 0;
            foreach (var workspace in workspaces)
            {
                workspaceMenu.Add(workspace.Name, createChildMenu(workspaceIndex));
                workspaceIndex++;
            }

            return workspaceMenu;
        });

        // Move window to workspace
        menuBuilder.AddMenu("move", () =>
        {
            var moveMenu = actionMenu.Create();
            var focusedWorkspace = context.Workspaces.FocusedWorkspace;

            var workspaces = context.WorkspaceContainer.GetWorkspaces(focusedWorkspace).ToArray();
            Func<int, Action> createChildMenu = (index) => () => { context.Workspaces.MoveFocusedWindowToWorkspace(index); };

            for (int i = 0; i < workspaces.Length; i++)
            {
                moveMenu.Add(workspaces[i].Name, createChildMenu(i));
            }

            return moveMenu;
        });

        // Rename workspace
        menuBuilder.AddFreeForm("rename", (name) =>
        {
            context.Workspaces.FocusedWorkspace.Name = name;
        });

        // Create workspace
        menuBuilder.AddFreeForm("create workspace", (name) =>
        {
            context.WorkspaceContainer.CreateWorkspace(name);
        });

        // Delete focused workspace
        menuBuilder.Add("close", () =>
        {
            context.WorkspaceContainer.RemoveWorkspace(context.Workspaces.FocusedWorkspace);
        });

        // Workspacer
        menuBuilder.Add("toggle keybind helper", () => context.Keybinds.ShowKeybindDialog());
        menuBuilder.Add("toggle enabled", () => context.Enabled = !context.Enabled);
        menuBuilder.Add("restart", () => context.Restart());
        menuBuilder.Add("quit", () => context.Quit());

        return menuBuilder;
    };
    var actionMenuBuilder = createActionMenuBuilder();

    /* Keybindings */
    Action setKeybindings = () =>
    {
        KeyModifiers alt = KeyModifiers.Alt;
        KeyModifiers altShift = KeyModifiers.Alt | KeyModifiers.Shift;
        KeyModifiers altCtrl = KeyModifiers.Alt | KeyModifiers.Control;

        IKeybindManager manager = context.Keybinds;

        var workspaces = context.Workspaces;

        manager.UnsubscribeAll();
        //
        //
        // Restart Workspacer
        manager.Subscribe(alt, Keys.R, () => context.Restart(), "restart workspacer");

        // Switch monitor using mouse
        manager.Subscribe(MouseEvent.LButtonDown, () => workspaces.SwitchFocusedMonitorToMouseLocation());

        // Send to primary window
        manager.Subscribe(alt, Keys.Back, () => workspaces.FocusedWorkspace.SwapFocusAndPrimaryWindow(), "swap focus and primary window");

        // Open terminal
        manager.Subscribe(alt, Keys.Enter, () => System.Diagnostics.Process.Start(@"C:\Users\ahzog\AppData\Local\Microsoft\WindowsApps\wt.exe"));

        // Quit window
        manager.Subscribe(alt, Keys.Q, () => workspaces.FocusedWorkspace.CloseFocusedWindow(), "close focused window");

        // Swtich monitor
        manager.Subscribe(alt, Keys.O, () => workspaces.MoveFocusedWindowToNextMonitor(), "switch monitor");

        // Window navigation
        manager.Subscribe(alt, Keys.J, () => workspaces.FocusedWorkspace.FocusNextWindow(), "focus next window");
        manager.Subscribe(alt, Keys.K, () => workspaces.FocusedWorkspace.FocusPreviousWindow(), "focus previous window");

        // Move windows to workspace
        manager.Subscribe(altShift, Keys.D1,() => workspaces.MoveFocusedWindowToWorkspace(0), "move focused window to workspace 1");
        manager.Subscribe(altShift, Keys.D2,() => workspaces.MoveFocusedWindowToWorkspace(1), "move focused window to workspace 2");
        manager.Subscribe(altShift, Keys.D3,() => workspaces.MoveFocusedWindowToWorkspace(2), "move focused window to workspace 3");
        manager.Subscribe(altShift, Keys.D4,() => workspaces.MoveFocusedWindowToWorkspace(3), "move focused window to workspace 4");
        manager.Subscribe(altShift, Keys.D5,() => workspaces.MoveFocusedWindowToWorkspace(4), "move focused window to workspace 5");
        manager.Subscribe(altShift, Keys.D6,() => workspaces.MoveFocusedWindowToWorkspace(5), "move focused window to workspace 6");

        // Switch to workspace
        manager.Subscribe(alt, Keys.D1, () => workspaces.SwitchToWorkspace(0), "switch to workspace 1");
        manager.Subscribe(alt, Keys.D2, () => workspaces.SwitchToWorkspace(1), "switch to workspace 2");
        manager.Subscribe(alt, Keys.D3, () => workspaces.SwitchToWorkspace(2), "switch to workspace 3");
        manager.Subscribe(alt, Keys.D4, () => workspaces.SwitchToWorkspace(3), "switch to workspace 4");
        manager.Subscribe(alt, Keys.D5, () => workspaces.SwitchToWorkspace(4), "switch to workspace 5");
        manager.Subscribe(alt, Keys.D6, () => workspaces.SwitchToWorkspace(5), "switch to workspace 6");

        manager.Subscribe(alt, Keys.Left, () => workspaces.SwitchToPreviousWorkspace(), "switch to previous workspace");
        manager.Subscribe(alt, Keys.Right, () => workspaces.SwitchToNextWorkspace(), "switch to next workspace");

        // Switch monitors
        manager.Subscribe(alt, Keys.H, () => workspaces.SwitchFocusedMonitor(0), "focus monitor 1");
        manager.Subscribe(alt, Keys.L, () => workspaces.SwitchFocusedMonitor(1), "focus monitor 2");

        // Swap the focused window with next/prev window
        manager.Subscribe(altShift, Keys.K, () => workspaces.FocusedWorkspace.SwapFocusAndNextWindow(), "swap focus and next window");
        manager.Subscribe(altShift, Keys.J, () => workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow(), "swap focus and previous window");

        // Resize Primary Window
        manager.Subscribe(altCtrl, Keys.H, () => workspaces.FocusedWorkspace.ShrinkPrimaryArea(), "shrink primary area");
        manager.Subscribe(altCtrl, Keys.L, () => workspaces.FocusedWorkspace.ExpandPrimaryArea(), "expand primary area");

        // GAPS
        manager.Subscribe(altCtrl, Keys.X, () => gapPlugin.IncrementInnerGap(), "increment inner gap");
        manager.Subscribe(altCtrl, Keys.Z, () => gapPlugin.DecrementInnerGap(), "decrement inner gap");
        manager.Subscribe(altShift, Keys.X, () => gapPlugin.IncrementOuterGap(), "increment outer gap");
        manager.Subscribe(altShift, Keys.Z, () => gapPlugin.DecrementOuterGap(), "decrement outer gap");

        // Other shortcuts
        manager.Subscribe(altShift, Keys.P, () => actionMenu.ShowMenu(actionMenuBuilder), "show menu");
        manager.Subscribe(altShift, Keys.Escape, () => context.Enabled = !context.Enabled, "toggle enabled/disabled");
        manager.Subscribe(altShift, Keys.I, () => context.ToggleConsoleWindow(), "toggle console window");
    };
    setKeybindings();
});
