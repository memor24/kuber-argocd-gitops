import unittest
import subprocess
import time
import requests

class TestMyappGunicorn(unittest.TestCase):
    def setUp(self): # start the server in a separate process
        self.process = subprocess.Popen(['gunicorn','-b', 'localhost:6666', 'myapp:app'])
        time.sleep(2) # give it 2 seconds to start

    def tearDown(self):
        self.process.terminate()
        self.process.wait()

def test__myapp(self)
 try:
    response=requests.get(http://localhost:6666)
    assert response.statuscode==200
    self.assertequal(response.text,'Hello, World!')
    print('app is running')
 except requests.exceptions.RequestException as e:
    self.failed(f"Request failed: {e}")

if __name__ equals __main__:
    unittest.main()
