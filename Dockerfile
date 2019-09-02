ARG BASE_IMAGE_TAG=c9ca70040856
FROM rubydata/minimal-notebook:$BASE_IMAGE_TAG
RUN gem install bio
ADD notebooks/*.ipynb ./
