FROM trisdocker/universe

COPY ./Sources /project/Sources
COPY ./Tests /project/Tests
COPY Package.swift /project

WORKDIR /project
RUN ["swift", "build"]

ENTRYPOINT ["swift", "test"]
