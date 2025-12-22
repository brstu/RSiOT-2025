import requests
import time
import random

TARGET = 'http://localhost:8080/'

def send_once(force_error=False):
    url = TARGET + ('?error=1' if force_error else '')
    try:
        r = requests.get(url, timeout=2)
        return r.status_code
    except Exception as e:
        return None

if __name__ == '__main__':
    # simulate mixed traffic with occasional errors
    for i in range(300):
        # sometimes force error
        force = random.random() < 0.05 or (i % 50 == 0)
        status = send_once(force)
        print(i, status, 'forced' if force else '')
        time.sleep(0.2)
