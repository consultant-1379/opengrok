"""
Helper class for start.py
"""

import threading
import time
from datetime import datetime
import schedule


class PeriodicTimer:
    """
    Helper class to facilitate waiting for (periodic) events.
    For periodic events, start() function has to be called first.
    """

    def __init__(self, time_value):
        """
        :param interval: interval in seconds, can be 0
        """
        self._time_value = time_value
        # self._interval = interval
        self._flag = 0
        self._cv = threading.Condition()

    def start(self):
        """
        Start the periodic notification thread if the configured interval is positive.
        """
        # if self._interval > 0:
        #     threading.Thread(target=self.run, daemon=True).start()
        if self._time_value != None:
            threading.Thread(target=self.run, daemon=True).start()

    def run(self):
        """
        Run the timer and notify waiting threads after each interval
        """
        
        # while True:
        #     if self._time_value < datetime.now().time():
        #         time.sleep(1)
        #     else:
        #         self.notify_all()
        # while True:
        #     time.sleep(self._interval)
        #     self.notify_all()
        schedule.every().day.at(self._time_value).do(self.notify_all)
        while True:
            schedule.run_pending()
            time.sleep(1)

    def wait_for_event(self):
        """
        Wait for the wakeup event. This can be either tick of the timer from run(),
        or notification via notify_all().
        """
        with self._cv:
            last_flag = self._flag
            while last_flag == self._flag:
                self._cv.wait()

    def notify_all(self):
        """
        Notify all listeners, possibly out of band.
        """
        with self._cv:
            self._flag ^= 1
            self._cv.notify_all()