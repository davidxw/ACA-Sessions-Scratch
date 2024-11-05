#https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples/blob/main/langchain-python-webapi/main.py

import os

import dotenv
from langchain import agents, hub
from langchain_azure_dynamic_sessions import SessionsPythonREPLTool
from langchain_openai import AzureChatOpenAI
from langchain_experimental.tools import PythonREPLTool

dotenv.load_dotenv()

#message="Write some code to print out the number of CPU cores"
message="Write and execute some code to print out the host name"

llm = AzureChatOpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    azure_deployment=os.getenv("AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME"),
    openai_api_version="2024-02-01",
    openai_api_type="azure_ad",
    temperature=0,
)

pool_management_endpoint = os.getenv("POOL_MANAGEMENT_ENDPOINT")

repl = PythonREPLTool()
#repl = SessionsPythonREPLTool(pool_management_endpoint=pool_management_endpoint)

tools = [repl]
prompt = hub.pull("hwchase17/openai-functions-agent")
agent = agents.create_tool_calling_agent(llm, tools, prompt)

agent_executor = agents.AgentExecutor(
    agent=agent, tools=tools, verbose=True, handle_parsing_errors=True
)

response = agent_executor.invoke({"input": message})

print(response["output"])