{ inputs, lib, buildPythonPackage, poetry-core, aiostream, dataclasses-json
, deprecated, fsspec, langchain, nest-asyncio, nltk, numpy, openai, pandas
, sqlalchemy, tenacity, tiktoken, typing-extensions, typing-inspect, urllib3
, relax-pyproject-dependencies
# , pytest, pytestCheckHook
# , optimum, sentencepiece, transformers, asyncpg, pgvector, psycopg-binary
# , guidance, jsonpath-ng, rank-bm25, scikit-learn, spacy, 
}:

buildPythonPackage rec {
  pname = "llama-index";
  version = inputs.llama-index-src.rev;
  # pyproject = true;
  format = "pyproject";

  src = inputs.llama-index-src;

  postPatch = ''
    ${relax-pyproject-dependencies}/bin/relax-pyproject-dependencies ./pyproject.toml
  '';

  nativeBuildInputs = [ poetry-core ];
  # pythonRelaxDeps = true;
  # pythonRemoveDeps = true;

  propagatedBuildInputs = [
    aiostream
    dataclasses-json
    deprecated
    fsspec
    langchain
    nest-asyncio
    nltk
    numpy
    openai
    pandas
    sqlalchemy
    tenacity
    tiktoken
    typing-extensions
    typing-inspect
    urllib3
  ];

  # passthru.optional-dependencies = {
  #   local_models = [ optimum sentencepiece transformers ];
  #   postgres = [ asyncpg pgvector psycopg-binary ];
  #   query_tools =
  #     [ guidance jsonpath-ng lm-format-enforcer rank-bm25 scikit-learn spacy ];
  # };

  # Simply importing the library already connects to an API...
  # pythonImportsCheck = [ "llama_index" ];
  # checkInputs = [ pytestCheckHook pytest ];

  meta = with lib; {
    description =
      "LlamaIndex (formerly GPT Index) is a data framework for your LLM applications";
    homepage = "https://github.com/run-llama/llama_index";
    changelog =
      "https://github.com/run-llama/llama_index/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
