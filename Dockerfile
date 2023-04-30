# 此Dockerfile适用于“无本地模型”的环境构建，如果需要使用chatglm等本地模型，请参考 docs/Dockerfile+ChatGLM
# 如何构建: 先修改 `config.py`， 然后 docker build -t gpt-academic .
# 如何运行: docker run --rm -it --net=host gpt-academic
FROM python:3.11

RUN echo '[global]' > /etc/pip.conf && \
    echo 'index-url = https://mirrors.aliyun.com/pypi/simple/' >> /etc/pip.conf && \
    echo 'trusted-host = mirrors.aliyun.com' >> /etc/pip.conf


WORKDIR /gpt
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

#需要使用sqlite进行用户认证，增加如下两行内容，注意文件需要和Dockerfile在一个目录下
RUN apt-get update && apt-get install -y sqlite3
COPY academic_chat.db ./gpt/academic_chat.db

# 可选步骤，用于预热模块
RUN python3  -c 'from check_proxy import warm_up_modules; warm_up_modules()'

CMD ["python3", "-u", "main.py"]
