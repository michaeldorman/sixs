check = function(.delay = 1, .screenshot = FALSE, remote_driver) {
  if(.screenshot) remote_driver$screenshot(display = FALSE, file = "rselenium_screenshot.png")
  Sys.sleep(1)
}
