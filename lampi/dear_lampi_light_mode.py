import pigpio
import colorsys
import time
import threading
import random

PIN_R = 19
PIN_G = 26
PIN_B = 13
PINS = [PIN_R, PIN_G, PIN_B]
PWM_RANGE = 100

_pi = pigpio.pi()
for pin in PINS:
    _pi.set_PWM_range(pin, PWM_RANGE)

current_thread = None
stop_event = threading.Event()

def stop_led():
    global current_thread
    stop_event.set()
    if current_thread and current_thread.is_alive() and threading.current_thread() != current_thread:
        print("Stopping LED effect")
        current_thread.join(timeout=1)
    for pin in PINS:
        _pi.set_PWM_dutycycle(pin, 0)

def twinkle():
    global current_thread
    stop_led()
    stop_event.clear()

    def animate():
        print("Starting RGB twinkle")
        while not stop_event.is_set():
            hue = 0.1
            saturation = 0.8
            brightness = random.uniform(0.1, 1.0)
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, brightness)
            _pi.set_PWM_dutycycle(PIN_R, int(r * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_G, int(g * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_B, int(b * PWM_RANGE))
            time.sleep(random.uniform(0.3, 0.6))

        stop_led()

    current_thread = threading.Thread(target=animate)
    current_thread.start()

def rainbow():
    global current_thread
    stop_led()
    stop_event.clear()

    def animate():
        print("Starting Rainbow light mode")
        hue = 0.0  # start at 0 hue (red)
        while not stop_event.is_set():
            saturation = 1.0
            brightness = 1.0
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, brightness)

            _pi.set_PWM_dutycycle(PIN_R, int(r * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_G, int(g * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_B, int(b * PWM_RANGE))

            hue += 0.01  # slowly cycle hues
            if hue >= 1.0:
                hue = 0.0

            time.sleep(0.05)

        stop_led()

    current_thread = threading.Thread(target=animate)
    current_thread.start()


def heartbeat():
    global current_thread
    stop_led()
    stop_event.clear()

    def animate():
        print("Starting Heartbeat light mode")
        hue = 0.0
        saturation = 1.0

        while not stop_event.is_set():
            # First beat
            brightness = 1.0
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, brightness)
            _pi.set_PWM_dutycycle(PIN_R, int(r * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_G, int(g * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_B, int(b * PWM_RANGE))
            time.sleep(0.3)

            brightness = 0.3
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, brightness)
            _pi.set_PWM_dutycycle(PIN_R, int(r * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_G, int(g * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_B, int(b * PWM_RANGE))
            time.sleep(0.3)

            # Second beat
            brightness = 0.7
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, brightness)
            _pi.set_PWM_dutycycle(PIN_R, int(r * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_G, int(g * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_B, int(b * PWM_RANGE))
            time.sleep(0.35)

            brightness = 0.0
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, brightness)
            _pi.set_PWM_dutycycle(PIN_R, int(r * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_G, int(g * PWM_RANGE))
            _pi.set_PWM_dutycycle(PIN_B, int(b * PWM_RANGE))
            time.sleep(0.45)

        stop_led()

    current_thread = threading.Thread(target=animate)
    current_thread.start()
