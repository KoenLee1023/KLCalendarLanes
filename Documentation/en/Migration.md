# Migration

Map an existing host event to `KLCalendarLaneEvent`, using a host-stable identifier and sorting key. Keep UI metadata in a lookup keyed by ID. Ask the engine for the current week or month interval, map returned segments to host bars, and use `coveredLaneCount(on:)` before placing same-day chips. Preserve your existing end-date convention by choosing `.exclusive` or `.inclusive` explicitly.
