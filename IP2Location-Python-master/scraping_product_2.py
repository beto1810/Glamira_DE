# scraping_utils.py

import requests
from bs4 import BeautifulSoup
import re
import logging

# Set up logging
logging.basicConfig(filename='scraping.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def scraping_product(link):
    name = category = gender = None
    image_urls = []

    try:
        response = requests.get(link)
        response.raise_for_status()  # Raises an HTTPError for bad responses (4xx and 5xx)
        soup = BeautifulSoup(response.content, 'html.parser')

        # Scraping name
        try:
            name = soup.find('span', class_='base').get_text()
        except AttributeError:
            logging.warning(f'Name not found for URL: {link}')
        
        # Scraping category
        try:
            category_tag = soup.find('script', text=re.compile(r'window.dataLayer.push'))
            category = re.search(r'"category":"([^"]+)"', category_tag.string).group(1)
        except (AttributeError, AttributeError, AttributeError):
            logging.warning(f'Category not found for URL: {link}')
        
        # Scraping gender
        try:
            gender = soup.find('tr', class_='item-gender').find(class_='detail-value').get_text()
        except AttributeError:
            logging.warning(f'Gender not found for URL: {link}')
        
        # Scraping images
        try:
            images = soup.find_all('img', class_='gallery-img')
            image_urls = [img['src'] for img in images]
        except AttributeError:
            logging.warning(f'Image URLs not found for URL: {link}')

    except requests.RequestException as e:
        logging.error(f'Request failed for URL: {link} with error: {e}')
    
    return name, category, gender, image_urls
