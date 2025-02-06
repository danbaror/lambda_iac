ARG FUNCTION_DIR="/function"

FROM public.ecr.aws/lambda/python:3.9 AS build-image

ARG FUNCTION_DIR

RUN mkdir -p ${FUNCTION_DIR}

COPY . ${FUNCTION_DIR}

RUN pip install -r ${FUNCTION_DIR}/requirements.txt --target ${FUNCTION_DIR}

FROM python:3.9-slim

ARG FUNCTION_DIR

WORKDIR ${FUNCTION_DIR}

COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]

CMD ["index.lambda_handler"]
