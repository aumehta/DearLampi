import pigpio
import colorsys
import time
import threading
import random

PIN_R = 19
PIN_G = 26
PIN_B = 13
PINS = [PIN_R, PIN_G, PIN_B]
PWM_RANGE = 100  # same as your original code

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
        # you could use a threading.Event to signal stop in production
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

        stop_led()  # Always turn off LED when done

    current_thread = threading.Thread(target=animate)
    current_thread.start()

