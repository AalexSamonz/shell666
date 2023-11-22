下拉菜单点击
from selenium import webdriver

driver = webdriver.Chrome()
driver.get("https://example.com/")

# 查找所有下拉菜单选项
options = driver.find_elements_by_xpath("//select[@id='my-select']/option")

# 选择第一个下拉菜单的第二个选项
options[1].click()




###google浏览器关键字搜索统计
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import requests
import chardet

import time
def get_url():
    # 创建一个浏览器实例
    driver = webdriver.Chrome()
    # driver.maximize_window()

    # 打开Google搜索页面
    driver.get("https://www.google.com/search?q=影视")
    # https://www.google.com/search?q=%E8%89%B2%E7%AB%99
    # 等待搜索结果加载完成
    get_order_loading_html = input("是否获取当前页面所有的链接？是按'y'")
    wait = WebDriverWait(driver, 100)

    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "#search")))

    # 循环点击下一页，直到最后一页

    # 获取当前页码
    current_page = driver.find_element(By.CSS_SELECTOR, "#xjs").text

    # 获取每个搜索结果的网站地址
    results = driver.find_elements(By.CSS_SELECTOR, "div.g")
    for result in results:
      link = result.find_element(By.CSS_SELECTOR, "a").get_attribute("href")
      print(link)
      with  open("weburl.txt", 'a') as f:
        f.write(link + "\n")

    # 判断当前页是否为最后一页
    #   if "下一页" not in current_page:
    #      break

    # 点击下一页按钮
    #next_button = driver.find_element(By.CSS_SELECTOR, "#pnnext")
    #next_button.click()

      # 等待下一页加载完成
    #   wait.until(EC.staleness_of(next_button))
    # time.sleep(100)
    # 关闭浏览器
    driver.quit()


gmails=[]

def find_emails():
    with open('weburl.txt','r') as  f:
      tt=f.readlines()
      for i in tt:
          url = i
          headers={'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"}
          try:
              ts=requests.get(url,headers=headers,timeout=10)
              html_content=ts.content
              match html_content:
                  case 1:
                      html = html_content.decode(('utf-8'))
              #emails=re.findall(r"[a-zA-Z0-9_.+-] +@(gmail.com|qq.com|outlook.com)",html)
                      emails = re.findall(r"[a-zA-Z0-9_.+-]+@[a-zA-Z-]+\.[a-zA-Z-.]+", html)
                      if emails:
                          print("地址 {0}的邮箱为：{1}".format(i,emails))
                          for n in emails:
                              with open('gmail.txt','a') as x:
                                  x.write(n + "\n")
                          gmails.append(emails)
                      else:
                          print("未找到相关页面邮箱" + i)
                  case 2:
                      html =chardet.detect(html_content)
                      emails = re.findall(r"[a-zA-Z0-9_.+-]+@[a-zA-Z-]+\.[a-zA-Z-.]+", html)
                      if emails:
                          print("地址 {0}的邮箱为：{1}".format(i, emails))
                          for n in emails:
                              with open('gmail.txt', 'a') as x:
                                  x.write(n + "\n")
                          gmails.append(emails)
                      else:
                          print("未找到相关页面邮箱" + i)
          except (requests.exceptions.ConnectTimeout,requests.exceptions.ConnectionError,requests.exceptions.ReadTimeout,requests.exceptions.TooManyRedirects):
              print(i+ "链接超时")


tst=[]
#去重文件
def filter_gmail():
    with open("gmail.txt",'r') as f,open('output_file.txt', 'w') as output_file:
        unique_mail=set(f)
        output_file.writelines(unique_mail)

#find_emails()
filter_gmail()
print(gmails)
print(tst)
