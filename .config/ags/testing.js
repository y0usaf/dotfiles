import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";

// Listen for changes in the Hyprland service
Hyprland.connect("changed", () => {
  // Log the current state of monitors
  console.log("Monitors:");
  Hyprland.monitors.forEach((monitor) => {
    console.log(`- ID: ${monitor.id}, Name: ${monitor.name}`);
  });

  // Get the count of monitors
  const monitorCount = Hyprland.monitors.length;
  console.log(`Monitor Count: ${monitorCount}`);

  // You can add more logging or testing logic here
});

// Listen for events from the Hyprland service
Hyprland.connect("event", (event, params) => {
  console.log(`Received event: ${event}`);
  console.log(`Params: ${params}`);
});

// Example: Send a test message to Hyprland
async function sendTestMessage() {
  try {
    const response = await Hyprland.sendMessage("test-message");
    console.log(`Response: ${response}`);
  } catch (error) {
    console.error("Error sending test message:", error);
  }
}

// Call the sendTestMessage function to test sending a message
sendTestMessage();
