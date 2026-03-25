use clap::{Parser, Subcommand};
use std::{fmt::Debug, str::FromStr};

#[derive(Parser)]
#[command(name = "niri-tools", version, about = "A simple CLI with subcommands", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Clone, Debug)]
enum Proportion {
    Fixed(u32),
    Fraction(u32),
}

impl TryFrom<&str> for Proportion {
    type Error = String;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let parts: Vec<&str> = value.split(':').collect();
        if parts.len() != 2 {
            return Err("invalid proportion".to_string());
        }
        let val = parts[1].parse::<u32>().map_err(|_| "Not a valid number")?;
        match parts[0] {
            "fixed" => Ok(Proportion::Fixed(val)),
            "frac" => Ok(Proportion::Fraction(val)),
            _ => Err("Prefix must be 'fixed' or 'frac'".to_string()),
        }
    }
}

impl FromStr for Proportion {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Proportion::try_from(s)
    }
}

impl Proportion {
    fn to_niri(&self) -> niri_ipc::SizeChange {
        match self {
            Proportion::Fixed(val) => niri_ipc::SizeChange::SetFixed(*val as i32),
            Proportion::Fraction(val) => niri_ipc::SizeChange::SetProportion(*val as f64),
        }
    }
}

#[derive(Subcommand, Debug)]
enum Command {
    /// Move into view and focus the window that matches the filters.
    ToggleScratch {
        /// Title, if set.
        #[arg(long)]
        title: Option<String>,

        /// Application ID, if set.
        #[arg(long)]
        app_id: Option<String>,

        /// Process ID that created the Wayland connection for this window, if known.
        #[arg(long)]
        pid: Option<i32>,

        /// Id of the workspace this window is on, if any.
        #[arg(long)]
        workspace_id: Option<u64>,

        /// Unique id of this window.
        #[arg(long)]
        id: Option<u64>,

        /// The workspace where the window is parked when not shown.
        #[arg(long)]
        scratch_workspace: String,

        /// The command executed when the window was not found.
        /// Use this to spawn the window.
        #[arg(long)]
        spawn_command: Option<String>,

        #[arg(long)]
        center: bool,

        /// Input format: 'fixed:N' or 'frac:N'
        #[arg(long, value_parser = Proportion::from_str)]
        width: Proportion,

        /// Input format: 'fixed:N' or 'frac:N'
        #[arg(long, value_parser = Proportion::from_str)]
        height: Proportion,
    },
}

fn error_handler(err: impl Debug) -> ! {
    eprintln!("error: {:?}", err);
    std::process::exit(1)
}

struct Filter<'a, T>(&'a Option<T>);

impl<'a, T> Filter<'a, T> {
    fn matches<O>(&'a self, other: &Option<O>) -> bool
    where
        T: PartialEq<O>,
    {
        match (self.0, other) {
            (Some(v), Some(o)) => v == o,
            (None, _) => true,
            _ => false,
        }
    }
}

struct NiriSocket {
    socket: niri_ipc::socket::Socket,
}

impl NiriSocket {
    fn new() -> Self {
        let socket = niri_ipc::socket::Socket::connect().unwrap_or_else(|err| error_handler(err));
        NiriSocket { socket }
    }

    fn send(&mut self, request: niri_ipc::Request) -> niri_ipc::Response {
        self.socket
            .send(request)
            .unwrap_or_else(|err| error_handler(err))
            .unwrap_or_else(|err| error_handler(err))
    }

    fn windows(&mut self) -> Vec<niri_ipc::Window> {
        let response = self.send(niri_ipc::Request::Windows);
        match response {
            niri_ipc::Response::Windows(windows) => windows,
            _ => error_handler("invalid response, requested Windows, got: {result:?}"),
        }
    }

    fn workspaces(&mut self) -> Vec<niri_ipc::Workspace> {
        let response = self.send(niri_ipc::Request::Workspaces);
        match response {
            niri_ipc::Response::Workspaces(workspaces) => workspaces,
            _ => error_handler("invalid response, requested Workspaces, got: {result:?}"),
        }
    }

    fn action(&mut self, action: niri_ipc::Action) -> niri_ipc::Response {
        self.send(niri_ipc::Request::Action(action))
    }
}

fn main() {
    let command = Cli::parse().command;
    let mut socket = NiriSocket::new();
    match command {
        Command::ToggleScratch {
            title,
            app_id,
            pid,
            workspace_id,
            id,
            scratch_workspace,
            spawn_command,
            center,
            width,
            height,
        } => {
            let windows = socket.windows();
            let found_window = windows.into_iter().find_map(|window| {
                if Filter(&title).matches(&window.title)
                    && Filter(&app_id).matches(&window.app_id)
                    && Filter(&pid).matches(&window.pid)
                    && Filter(&workspace_id).matches(&window.workspace_id)
                    && Filter(&id).matches(&Some(window.id))
                {
                    Some(window)
                } else {
                    None
                }
            });
            let workspaces = socket.workspaces();
            let focused_workspace_id = workspaces
                .iter()
                .find_map(|workspace| {
                    if workspace.is_focused {
                        Some(workspace.id)
                    } else {
                        None
                    }
                })
                .unwrap_or_else(|| error_handler("no focused workspace"));
            let scratch_workspace_id = workspaces
                .iter()
                .find_map(|workspace| match &workspace.name {
                    Some(name) if *name == scratch_workspace => Some(workspace.id),
                    _ => None,
                })
                .unwrap_or_else(|| error_handler("the scratch workspace does not exist"));
            match found_window {
                Some(window) => {
                    let should_show = !window.is_focused
                        || matches!(window.workspace_id, Some(workspace_id) if workspace_id != focused_workspace_id);
                    if should_show {
                        // make floating
                        if !window.is_floating {
                            socket.action(niri_ipc::Action::ToggleWindowFloating {
                                id: Some(window.id),
                            });
                        }
                        // reshape
                        socket.action(niri_ipc::Action::SetWindowWidth {
                            id: Some(window.id),
                            change: width.to_niri(),
                        });
                        socket.action(niri_ipc::Action::SetWindowHeight {
                            id: Some(window.id),
                            change: height.to_niri(),
                        });
                        // move to focused workspace
                        socket.action(niri_ipc::Action::MoveWindowToWorkspace {
                            window_id: Some(window.id),
                            reference: niri_ipc::WorkspaceReferenceArg::Id(focused_workspace_id),
                            focus: false,
                        });
                        // focus
                        socket.action(niri_ipc::Action::FocusWindow { id: window.id });
                        if center {
                            socket.action(niri_ipc::Action::CenterWindow {
                                id: Some(window.id),
                            });
                        }
                    } else {
                        // move to scratchpad
                        socket.action(niri_ipc::Action::MoveWindowToWorkspace {
                            window_id: Some(window.id),
                            reference: niri_ipc::WorkspaceReferenceArg::Id(scratch_workspace_id),
                            focus: false,
                        });
                    };
                }
                None => {
                    if let Some(command) = spawn_command {
                        let os_str = std::ffi::OsStr::new(&command);
                        let mut sys = sysinfo::System::new_all();
                        sys.refresh_all();
                        let is_not_running = sys.processes_by_exact_name(&os_str).next().is_none();
                        if is_not_running {
                            socket.action(niri_ipc::Action::SpawnSh { command });
                        }
                    }
                }
            }
        }
    };
}
