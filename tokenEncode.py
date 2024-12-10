import sys
import base64

token = sys.argv[1]
encodeToken = base64.b64encode(bytes(token, 'utf-8'))
print(encodeToken)
