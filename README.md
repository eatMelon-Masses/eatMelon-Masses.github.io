# yiezi.github.io
yiezi的个人博客

# docker 环境拉取镜像和部署命令
    docker pull  registry.cn-chengdu.aliyuncs.com/yiezi/blog
    docker run -p 80:4000 -d --name blog registry.cn-chengdu.aliyuncs.com/yiezi/blog:latest jekyll serve

