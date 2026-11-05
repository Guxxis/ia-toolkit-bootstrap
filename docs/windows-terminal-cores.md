# Cores do terminal — esquema "Papel Amarelo" (Windows Terminal)

Fica fora do WSL, em `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`, então o playbook não aplica — é manual no Windows.

## Como aplicar em outro PC

1. Windows Terminal → `Ctrl+,` → **Abrir arquivo JSON** (canto inferior esquerdo).
2. Colar o objeto abaixo dentro do array `"schemes"`.
3. No perfil **Ubuntu** de `profiles.list` (o que tem `"source": "CanonicalGroupLimited.Ubuntu_..."`), adicionar as três chaves do bloco "Perfil". Não copiar o `guid` — ele é gerado por máquina.
4. Salvar; o terminal recarrega sozinho.

O Claude Code usa `"theme": "light-ansi"` (versionado em `settings/claude-settings.json`), que herda essa paleta ANSI do terminal.

## Esquema

```json
{
    "name": "Papel Amarelo",
    "background": "#F6E8A6",
    "foreground": "#2B2B2B",
    "cursorColor": "#2B2B2B",
    "selectionBackground": "#E3D38A",
    "black": "#2B2B2B",
    "red": "#B3412F",
    "green": "#4F6F2A",
    "yellow": "#8A6A00",
    "blue": "#2F5D8A",
    "purple": "#7A3E7A",
    "cyan": "#2E7272",
    "white": "#D9CB8C",
    "brightBlack": "#8C8360",
    "brightRed": "#C8553F",
    "brightGreen": "#5E8233",
    "brightYellow": "#A07C00",
    "brightBlue": "#3A6FA3",
    "brightPurple": "#8E4C8E",
    "brightCyan": "#378787",
    "brightWhite": "#FFF8D6"
}
```

## Perfil

```json
"colorScheme": "Papel Amarelo",
"cursorColor": "#121212",
"intenseTextStyle": "bright"
```
