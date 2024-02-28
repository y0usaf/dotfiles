import App from "resource:///com/github/Aylur/ags/app.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import Notifications from "resource:///com/github/Aylur/ags/service/notifications.js";
import Mpris from "resource:///com/github/Aylur/ags/service/mpris.js";
import Audio from "resource:///com/github/Aylur/ags/service/audio.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";
import SystemTray from "resource:///com/github/Aylur/ags/service/systemtray.js";
import {
  execAsync,
  monitorFile,
} from "resource:///com/github/Aylur/ags/utils.js";

const workspaces = () =>
  Widget.Box({
    class_name: "workspaces",
    children: Hyprland.bind("workspaces").transform((ws) =>
      (Array.isArray(ws) ? ws : [])
        .sort((a, b) => a.id - b.id)
        .map(({ id }) =>
          Widget.Button({
            on_clicked: () => Hyprland.sendMessage(`dispatch workspace ${id}`),
            child: Widget.Label(`${id}`),
            class_name: Hyprland.active.workspace
              .bind("id")
              .transform((i) => (i === id ? "focused" : "")),
          }),
        ),
    ),
  });

const clientTitle = () =>
  Widget.Button({
    class_name: "client-title",
    label: Hyprland.active.client.bind("title"),
  });

const clock = () =>
  Widget.Button({
    class_name: "clock",
    setup: (self) =>
      self.poll(1000, (self) =>
        execAsync(["date", "+%H:%M:%S %b %e."]).then(
          (date) => (self.label = date),
        ),
      ),
  });

const cpuTemperature = () =>
  Widget.Button({
    class_name: "cpu-temperature-label",
    label: "CPU: -",
    setup: (self) => {
      const update = async () => {
        const sensorOutput = await execAsync(["sensors"]);
        const temperature =
          sensorOutput.match(/Tctl:\s+\+(\d+\.\d+)/)?.[1] + "°C" || "N/A";
        self.label = `CPU: ${temperature}`;
      };
      self.poll(1000, update);
      update();
    },
  });

const notification = () =>
  Widget.Box({
    class_name: "notification",
    visible: Notifications.bind("popups").transform((p) => p.length > 0),
    children: [
      Widget.Icon({
        icon: "preferences-system-notifications-symbolic",
      }),
      Widget.Label({
        label: Notifications.bind("popups").transform(
          (p) => p[0]?.summary || "",
        ),
      }),
    ],
  });

const media = () =>
  Widget.Button({
    class_name: "media",
    on_primary_click: () => Mpris.getPlayer("")?.playPause(),
    on_scroll_up: () => Mpris.getPlayer("")?.next(),
    on_scroll_down: () => Mpris.getPlayer("")?.previous(),
    child: Widget.Label("-").hook(
      Mpris,
      (self) => {
        if (Mpris.players[0]) {
          const { track_artists, track_title } = Mpris.players[0];
          self.label = `${track_artists.join(", ")} - ${track_title}`;
        } else {
          self.label = "Nothing is playing";
        }
      },
      "player-changed",
    ),
  });

const volume = () =>
  Widget.Button({
    class_name: "volume-button",
    on_clicked: () => {},
    child: Widget.Box({
      class_name: "volume",
      children: [
        Widget.Icon().hook(
          Audio,
          (self) => {
            if (!Audio.speaker) return;
            const category = {
              101: "overamplified",
              67: "high",
              34: "medium",
              1: "low",
              0: "muted",
            };
            const icon = Audio.speaker.is_muted
              ? 0
              : [101, 67, 34, 1, 0].find(
                  (threshold) => threshold <= Audio.speaker.volume * 100,
                );
            self.icon = `audio-volume-${category[icon]}-symbolic`;
          },
          "speaker-changed",
        ),
        Widget.Label({
          class_name: "volume-label",
          setup: (self) =>
            self.hook(
              Audio,
              () =>
                (self.label = ` Vol: ${
                  Math.round(Audio.speaker?.volume * 100) || 0
                }%`),
              "speaker-changed",
            ),
        }),
      ],
    }),
  });

const batteryLabel = () =>
  Widget.Button({
    class_name: "battery-label-button",
    on_clicked: () => {},
    child: Widget.Box({
      class_name: "battery",
      visible: Battery.bind("available"),
      children: [
        Widget.Icon({
          icon: Battery.bind("percent").transform(
            (p) => `battery-level-${Math.floor(p / 10) * 10}-symbolic`,
          ),
        }),
        Widget.ProgressBar({
          vpack: "center",
          fraction: Battery.bind("percent").transform((p) =>
            p > 0 ? p / 100 : 0,
          ),
        }),
      ],
    }),
  });

const sysTray = () =>
  Widget.Box({
    children: SystemTray.bind("items").transform((items) =>
      items.map((item) =>
        Widget.Button({
          child: Widget.Icon({ binds: [["icon", item, "icon"]] }),
          on_primary_click: (_, event) => item.activate(event),
          on_secondary_click: (_, event) => item.openMenu(event),
          binds: [["tooltip-markup", item, "tooltip-markup"]],
        }),
      ),
    ),
  });

monitorFile(`${App.configDir}/style.scss`, () => {
  App.resetCss();
  App.applyCss(`${App.configDir}/style.scss`);
});

const createBar = (position, monitor) => {
  const Center = Widget.Box({
    spacing: 2,
    children: [
      media(),
      notification(),
      volume(),
      batteryLabel(),
      workspaces(),
      clock(),
      cpuTemperature(),
      sysTray(),
      clientTitle(),
    ],
  });

  return Widget.Window({
    name: `${position}-bar-${monitor}`,
    class_name: "bar",
    monitor,
    anchor: [position],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      center_widget: Center,
    }),
  });
};

const numberOfMonitors = 2; // Replace with the actual number of monitors

const bars = Array.from({ length: numberOfMonitors }, (_, monitor) => [
  createBar("top", monitor),
  createBar("bottom", monitor),
]).flat();

export default {
  style: `${App.configDir}/style.scss`,
  windows: bars.flat(1),
};
