# DelphiMultipleWindowsService
Exemplo em Delphi, de como criar um serviço do windows que permita multiplas instalações a partir do mesmo .exe, para isso é necessário passar um segundo parâmetro na instalação para definir nomes diferentes para os serviços.
Exemplo:
MeuServico.exe /install Servico1
MeuServico.exe /install Servico2
