import requests
from bs4 import BeautifulSoup
import time
import os

# pip install requests beautifulsoup4 lxml

headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
link_base = 'https://bing.wdbyte.com'

def download_pic(folder,name,url):
    os.system(f'mkdir -p "{folder}"')
    file_path = f'{folder}/{name}.jpg'
    if os.path.exists(file_path):
        print(f"File Exists: {file_path}")
        return
    print(f'downloading: {file_path}')
    os.system(f'wget "{url}" -q -O {file_path}')

def scrape_4k(date,url):
    try:
        # 1. 发送 HTTP GET 请求
        response = requests.get(url, headers=headers, timeout=10) # 设置超时10秒
        response.raise_for_status() # 如果请求失败 (状态码不是 2xx), 则抛出异常

        # 2. 解析 HTML 内容
        # 使用 'lxml' 解析器，如果未安装 lxml，可以使用 'html.parser'
        soup = BeautifulSoup(response.text, 'lxml')

        # 3. 提取数据
        links = []
        pic_elements = soup.find_all('div', class_='w3-third') # 查找所有 class 为 'w3-third' 的 div 元素

        for pic_element in pic_elements:
            link = pic_element.find('a', string="Download 4k").get('href')
            title = pic_element.find('p').get_text().split(' ')[0]
            download_pic(date, title, link)
            # time.sleep(1)

    except requests.exceptions.RequestException as e:
        print(f"请求错误: {e}")
        return None
    except Exception as e:
        print(f"发生其他错误: {e}")
        return None

def get_all():
    print("starting....")
    # 1. 发送 HTTP GET 请求
    response = requests.get(link_base, headers=headers, timeout=10) # 设置超时10秒
    response.raise_for_status() # 如果请求失败 (状态码不是 2xx), 则抛出异常
    
    # 2. 解析 HTML 内容
    soup = BeautifulSoup(response.text, 'lxml')

    pages = soup.find_all('a', class_ = 'w3-tag w3-button w3-hover-green w3-light-grey w3-margin-bottom')

    for page in pages:
        link=link_base+'/'+page.get('href')
        date=page.get('href').split('.')[0]
        time.sleep(1)
        print(f'visiting: {link}')
        scrape_4k(date,link)

if __name__ == "__main__":
    get_all() 

