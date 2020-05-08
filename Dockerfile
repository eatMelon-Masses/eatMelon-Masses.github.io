FROM jekyll/minimal
COPY . /srv/jekyll
CMD jekyll serve
