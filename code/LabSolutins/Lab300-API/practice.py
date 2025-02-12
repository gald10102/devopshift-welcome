import httpx
import time

def get_url_n_times(url:str,headers=None,retries=1):
    uurl = url
    uheaders=headers
    uretries =retries
    for i in range(uretries):
        try:
            print (f"fetching data attempt {i+1} out of {uretries}")
            response = httpx.get(uurl,headers=uheaders)
            data = response.json()
            if response.status_code == 404:
                print("data not found")
                break
            if response.status_code == 500:
                print("server error")
                break
            return data
            response.raise_for_status()
        except httpx.ConnectError:
            if i+1==uretries:    
                print("All retry attempts failed.")
                break
            print("Server is currently down, \nRetrying...")
            time.sleep(2)
        else:
            print(data)



#Part 1
url = "https://jsonplaceholder.typicode.com/users/1"
data = get_url_n_times(url,retries=1) #data is user information
print("Username:",data["name"]) #prints the first user's name
print("Email:",data["email"]) #user's email
print("Address:",data["address"]["street"],",",data["address"]["city"]) #users address

#Part 2
url = "https://api.example.com/system/metrics?metrics=cpu,memory"
headers={"Authorization": "Bearer YOUR_API_KEY"}
retries =3
get_url_n_times(url,headers=headers,retries=retries)