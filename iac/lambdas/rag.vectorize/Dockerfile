FROM public.ecr.aws/lambda/python:3.13 AS base
FROM base AS runner

# Install the dependencies

WORKDIR ${LAMBDA_TASK_ROOT}

COPY shared/src/shared/ ./shared/
COPY rag.vectorize/requirements.txt .
COPY rag.vectorize/handler.py .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["handler.handler"]