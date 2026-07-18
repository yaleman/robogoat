const state = { gear: "direct", motor: "mechanical", traction: "engagement" };
const form = document.querySelector("#calculator");
const errorBox = document.querySelector("#form-error");
let timer;

const number = (id) => Number(document.querySelector(`#${id}`).value);
const show = (id, visible) => document.querySelector(`#${id}`).classList.toggle("hidden", !visible);
const format = (value, digits = 2) => Number.isFinite(value) ? value.toFixed(digits) : "—";

function payload() {
  const gearing = state.gear === "direct"
    ? { kind: "direct", reduction_ratio: number("reduction_ratio") }
    : { kind: "teeth", motor_teeth: number("motor_teeth"), driven_teeth: number("driven_teeth") };
  let motor;
  if (state.motor === "dc") {
    motor = {
      kind: "dc_curve", voltage_v: number("voltage_v"), no_load_rpm: number("no_load_rpm"),
      no_load_current_a: number("no_load_current_a"), stall_torque_nm: number("stall_torque_nm"),
      stall_current_a: number("stall_current_a")
    };
  } else if (document.querySelector('[name="mechanical-kind"]:checked').value === "power") {
    motor = { kind: "mechanical_power", loaded_rpm: number("loaded_rpm"), power_w: number("power_w") };
  } else {
    motor = { kind: "mechanical_torque", loaded_rpm: number("loaded_rpm"), torque_nm: number("torque_nm") };
  }
  return {
    sprocket_diameter_mm: number("sprocket_diameter_mm"), robot_mass_kg: number("robot_mass_kg"),
    incline_deg: number("incline_deg"), motor_count: number("motor_count"),
    drivetrain_efficiency: number("drivetrain_efficiency") / 100,
    rolling_resistance: number("rolling_resistance"), traction_coefficient: number("traction_coefficient"),
    traction_mode: state.traction === "engagement" ? "positive_engagement" : "friction_only",
    gearing, motor
  };
}

function validationMessage(body) {
  if (!Array.isArray(body.detail)) return "Could not calculate with these values.";
  return body.detail.map((item) => `${item.loc.slice(1).join(" → ")}: ${item.msg}`).join(" · ");
}

function render(result) {
  const results = document.querySelector("#results");
  results.className = `status-${result.status}`;
  document.querySelector("#status").textContent = result.status;
  document.querySelector("#sustainable_speed_kmh").textContent = format(result.sustainable_speed_kmh);
  document.querySelector("#sustainable_speed_mps").textContent = `${format(result.sustainable_speed_mps)} m/s`;
  document.querySelector("#power_budget_percent").textContent = `${format(result.power_budget_percent, 0)}%`;
  const meter = document.querySelector("#power-meter");
  meter.style.width = `${Math.min(100, result.power_budget_percent)}%`;
  meter.style.background = result.power_budget_percent > 100 ? "var(--red)" : result.power_budget_percent >= 80 ? "var(--amber)" : "var(--lime)";
  document.querySelector("#power-detail").textContent = `${format(result.required_power_w, 1)} W required / ${format(result.available_power_w, 1)} W available`;
  document.querySelector("#theoretical_speed_kmh").textContent = `${format(result.theoretical_speed_kmh)} km/h`;
  document.querySelector("#maximum_incline_deg").textContent = `${format(result.maximum_incline_deg, 1)}°`;
  document.querySelector("#force").textContent = `${format(result.required_force_n, 1)} / ${format(result.available_force_n, 1)} N`;
  document.querySelector("#required_wheel_torque_nm").textContent = `${format(result.required_wheel_torque_nm, 2)} N·m`;
  document.querySelector("#motor-torque").textContent = `${format(result.required_motor_torque_nm, 3)} / ${format(result.available_motor_torque_nm, 3)} N·m`;
  document.querySelector("#result-ratio").textContent = `${format(result.reduction_ratio, 2)} : 1`;
  document.querySelector("#limiting_factor").textContent = result.limiting_factor;
  const hasCurrent = result.estimated_total_current_a !== null;
  show("current-result", hasCurrent);
  if (hasCurrent) document.querySelector("#estimated_total_current_a").textContent = `${format(result.estimated_total_current_a, 1)} A`;
  document.querySelector("#warnings").innerHTML = result.warnings
    .map((warning) => `<div class="warning ${warning.severity}">${warning.message}</div>`).join("");
}

async function calculate() {
  try {
    const response = await fetch("/api/calculate", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(payload()) });
    const body = await response.json();
    if (!response.ok) throw new Error(validationMessage(body));
    errorBox.classList.add("hidden");
    render(body);
  } catch (error) {
    errorBox.textContent = error.message === "Failed to fetch" ? "The calculator service is not reachable." : error.message;
    errorBox.classList.remove("hidden");
  }
}

function scheduleCalculation() { clearTimeout(timer); timer = setTimeout(calculate, 180); }

document.querySelectorAll(".segmented button").forEach((button) => button.addEventListener("click", () => {
  document.querySelectorAll(`[data-group="${button.dataset.group}"]`).forEach((item) => item.classList.remove("active"));
  button.classList.add("active");
  state[button.dataset.group] = button.dataset.value;
  show("gear-direct", state.gear === "direct"); show("gear-teeth", state.gear === "teeth");
  show("motor-mechanical", state.motor === "mechanical"); show("motor-dc", state.motor === "dc");
  show("traction-field", state.traction === "friction");
  scheduleCalculation();
}));
document.querySelectorAll('[name="mechanical-kind"]').forEach((radio) => radio.addEventListener("change", () => {
  const power = radio.value === "power" && radio.checked;
  if (radio.checked) { show("power-field", power); show("torque-field", !power); scheduleCalculation(); }
}));
form.addEventListener("input", scheduleCalculation);
calculate();
