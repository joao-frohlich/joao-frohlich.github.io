---
layout: post
title:  "Introdução a Análise Estática de Programas - Representação Intermediária"
date:   2024-11-03 18:12:00 -0300
category: Compilers
lang: ptbr
---

### Introdução

Bem, hora de escrever algum conteúdo de fato nesse site.

Eu queria começar falando direto sobre alguma coisa que eu estou trabalhando no mestrado mas, parando pra pensar, eu abordaria conteúdos que algumas pessoas provavelmente nunca sequer ouviram falar, e eu trataria com a naturalidade que eu normalmente trato vendo eles todos os dias no mestrado.

Por isso, decidi iniciar aqui uma série de postagens introdutórias sobre Análise Estática de Programas, que é uma parte muito importante de otimização de compiladores, e que provavelmente eu vou usar muitos conteúdos dessa área em postagens futuras (talvez tudo seja sobre análise estática, mas espero que não).

Como um pontapé inicial dessa série de postagens, eu acho crucial falar de um assunto muito importante, que são as representações intermediárias (RI). De modo geral, uma representação intermediária é uma forma como o código é representado durante as etapas de compilação até que ele vire código de máquina. Normalmente, uma representação intermediária vai ser independente da arquitetura (x86, arm, risc-v, etc...) para a qual o código está sendo compilado, e tais representações permitem visualizar pontos onde um código pode ser otimizado.

Para começar tratando de RI, vou começar falando sobre duas representações muito simples (pelo menos do meu ponto de vista, e eu sou péssimo para julgar a complexidade de algo): Código de Três Endereços (Three Address Code) e Grafo de Fluxo de Controle

Uma pequena observação: eu não vou terminar essa postagem de primeira. Conforme eu for vendo a necessidade, eu vou adicionando novas representações intermediárias aqui e vou apontando nas postagens que usarem esses novos conteúdos.

### Código de Três Endereços

A RI de Código de Três Endereços (tradução livre feita por mim, não me recordo de ver na literatura alguma tradução para esse termo) é uma representação onde cada instrução do código fonte é traduzida para uma sequência de instruções que possuem, no máximo, três endereços: dois para operandos e um para o resultado, que é onde o valor da operação será armazenado. Vale ressaltar que o código final lembra um pouco um código assembly, e de fato a tradução dessa representação para código de máquina (com muitas ressalvas aqui, porque existe muita otimização feita em cima desse código) passa muito pela adaptação dos operadores para instruções específicas de cada arquitetura.

Algumas coisas importantes sobre essa RI:
- Ela se utiliza de diversas variáveis temporárias para armazenar valores;
- As instruções são ordenadas na ordem que elas devem ser executadas, e supostamente deveriam ser executadas uma após a outra, a menos que tenha uma instrução de pulo ou ramificação;
- Ela insere etiquetas no código para manter a informação do fluxo de controle do programa. Vale ressaltar que essas etiquetas não são comandos executáveis.

Dadas essas propriedades, podemos definir as seguintes operações:
- Atribuição: `a = b`
- Operação unária: `a = op b`
- Operação binária: `a = b op c` ou `a = op b c`
- Ramificação: `br cmp L1 L2`
- Pulo: `jmp L`
- Retorno: `ret a`

Onde:
- a, b, c e cmp são variáveis (cmp é uma variável booleana)
- op é um operador (+, -, *, /, %, etc...)
- L, L1 e L2 são etiquetas

Para exemplificar, vamos supor o seguinte código em C:

```c
int foo() {
    int a,b,c;
    a = 2;
    b = a*2;
    if (b <= a*3) {
        c = 5;
    } else {
        c = 3;
    }
    return a+b+c;
}
```

Dada a definição acima, esse código seria traduzido para o seguinte Código de Três Endereços:

```
a = 2
b = a * 2
t1 = a * 3
cmp = b <= t1
br cmp L1 L2
L1:
    c = 5
    jmp L3
L2:
    c = 3
L3:
    r = a + b
    r = r + c
    ret r
```

### Grafo de Fluxo de Controle (GFC)

Antes de continuar, acho válido definir o que é o fluxo de controle de um programa. Basicamente, o fluxo de controle é a ordem em que as instruções são executadas.

A partir da RI de Código de Três Endereços, nós podemos derivar uma outra representação intermediária que facilita a visualização do fluxo de controle do nosso código. Essa RI é chamada de Grafo de Fluxo de Controle. Portanto, como é um grafo (direcionado, nesse caso), sabemos que ele precisa de um conjunto de vértices e um conjunto de arestas. Portanto, dado um Código de Três Endereços, o que é vértice e o que é aresta nele?

Bom, eu espero que você ainda lembre que o Código de Três Endereços mantém as instruções na ordem que elas devem ser executadas (com exceção de ramificações e pulos). Portanto, se nós temos uma sequência de instruções que não alteram o fluxo de controle do programa (isto é, não fazem pulos para outras partes do código), você concorda que nós podemos agrupar estas instruções em uma estrutura tipo, sei lá, um vértice?

Pois bem, esses vértices num GFC são o que chamamos de **blocos básicos** de um programa. De fato, todas as instruções de um bloco básico não alteram o fluxo de controle do programa, com exceção da última instrução, que pode tanto terminar o programa (ou seja, uma instrução de retorno) ou mudar o fluxo de controle (ou seja, uma instrução de ramificação ou pulo).

Bom, nós definimos qual é a última instrução de um bloco básico, mas não seria mais fácil saber também qual seria a primeira instrução de cada bloco básico? Sim, e de fato, existe até uma denominação para essas instruções: **cabeçalhos de bloco básico** (tradução livre de novo, o termo em inglês é _basic block headers_). Nas nossas definições de Código de Três Endereços, nós temos duas definições para cabeçalhos de bloco básico:
- a primeira instrução de um programa é um cabeçalho de um bloco básico;
- a instrução que sucede uma etiqueta é um cabeçalho de um bloco básico.

Agora que temos o conjunto de vértices do nosso grafo definido, precisamos definir o conjunto de arestas que, lembrando, são direcionadas. Para isso, vamos definir as arestas que saem dos blocos. Ou melhor, começaremos definindo aquelas que não saem, isto porque o bloco básico que termina o programa (cuja última instrução é um retorno) não possuí nenhuma aresta de saída. Para os outros blocos básicos, basta olhar para as etiquetas para onde as últimas instruções apontam, e se lembrar que essas etiquetas indicam quem são os blocos básicos. Então, será criada uma aresta com origem no bloco básico que tem essa instrução de modificação de fluxo de controle e com destino no bloco básico para o qual essa modificação de fluxo é dirigida.

E bem, para exemplificar, eu gostaria muito de usar uma imagem aqui, mas eu não estou muito bem acostumado com o Jekyll ainda, então eu vou usar de um recurso muito simples (mas que fica péssimo em telas pequenas): ASCII art. Puxando do nosso exemplo de Código de Três Endereços, eu vou separar aquele código em blocos básicos e renomear as etiquetas para o nome dos blocos básicos para onde elas apontam:

```
-------------- bb0
a = 2
b = a * 2
t1 = a * 3
cmp = b <= t1
br cmp bb1 bb2
--------------

-------------- bb1
c = 5
jmp bb3
--------------

-------------- bb2
c = 3
--------------

-------------- bb3
r = a + b
r = r + c
ret r
--------------
```

Agora, para representar as arestas, vou só usar os nomes. E lembre-se que as arestas têm direção, que nesse caso é de cima para baixo.

```
    bb0
    / \
  bb1  bb2
    \ /
    bb3
```

Ahnn, isso ficou pior do que eu esperava, e eu certamente vou melhorar isso depois, mas espero que o exemplo tenha ficado claro sobre como que GFCs funcionam.

### Conclusão (Parcial)

Acho que eu cobri o básico (e talvez o essencial) de Código de Três Endereços e Grafo de Fluxo de Controle nessa postagem. E de verdade, eu espero que tenha dado para entender, porque esse assunto é muito importante para várias coisas que eu vou escrever aqui.

Não sei com qual frequência que eu vou escrever postagens por aqui, então não crie expectativas de ver novas postagens, afinal o mestrado consome tempo, mas talvez nos veremos em breve. De qualquer forma, se quiser conversar comigo sobre o que eu escrevi aqui... bem, meu email tá no [sobre]({{ "/about" | relative_url }}).

### Referências

Para escrever essa postagem, eu usei como material principal as [aulas do meu orientador sobre Análise Estática de Programas](https://homepages.dcc.ufmg.br/~fernando/classes/dcc888/ementa/).

Se você quiser mais materiais sobre o assunto, recomendo a página da [bibliografia do mesmo curso](https://homepages.dcc.ufmg.br/~fernando/classes/dcc888/biblio.html).