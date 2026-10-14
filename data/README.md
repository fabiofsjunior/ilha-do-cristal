# Conteúdo versionado

O catálogo de planejamento [`catalogs/mvp.json`](catalogs/mvp.json) corresponde às [doze listas de produção](../Docs/Main/CATALOGS_MVP.md). Possui IDs estáveis e `schema_version`, mas alguns campos são provisórios ou pendentes. Validar com `python tools/validate_catalogs.py` na raiz antes de cada PR que o alterar. Nos sprints S0/S2, dividir em definições consumíveis pelo Godot e fechar schemas/contratos. Não duplicar fórmulas em JSON e GDScript sem testes; ainda não há conteúdo executável.
