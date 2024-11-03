---
layout: post
title:  "Introduction to Program Static Analysis - Intermediate Representation"
date:   2024-11-03 18:12:00 -0300
category: Compilers
lang: en
---

### Introduction

So, it's time for a first content post.

For this, since I'll be talking a lot about compiler optimizations, specially static analysis, I've decided to write some posts explaining basic concepts of program static analysis. Then, as a first post to this series, I will try to explain some types of intermediate representation (IR).

I think it's good to let it clear that I won't complete this post on a first writing, but rather I'll be updating this post as I see the need for this. So, every time I write something that needs an IR that I didn't explained here before, I'll probably point out that the topic was added here.

Then, let's start this post talking about two basic IRs: Three Address Code and Control Flow Graph.

### Three Address Code (TAC)

The Three Address Code is an IR where every instruction in the source code is translated into a set of instructions that contains at most three addresses each, which are used for two operands and a result, where the value of the operation is stored (if needed). It might be needless to say, but every instruction in this IR also contains an operator. 

Some important things to note about TAC:
- it makes use of a lot of temporary variables to store values;
- the instructions are kept ordered, and are intended to be executed one after another, unless there is a branch or jump instruction;
- it insert labels on the result code to maintain the control flow (i.e. the order the code is intended to be executed). These labels aren't instructions, just placeholders.

Given this properties, we can define the following operations:
- Assign: `a = b`;
- Unary operation: `a = op b`;
- Binary operation: `a = b op c` or `a = op b c`;
- Branch: `br cmp L1 L2`;
- Jump: `jmp L`;
- Return: `ret a`;

Where:
- a, b, c and cmp are variables (cmp is a boolean variable);
- op is an operator (+, -, *, /, %...);
- L, L1 and L2 are labels.

So, suppose the following C code:

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

A Three Address Code representation of this would be (in our set of operations defined above):

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

### Control Flow Graph (CFG)

From the TAC IR, we can derive another intermediate representation which makes it easier to visualize the control flow of our programs. Such IRs are called Control Flow Graphs. Since it is a graph, more specifically a directed graph, it must contain a set of vertices and a set of edges, right? So, who are the vertices and edges in the TAC?

Let's break down some things here: remember that the TAC keeps the instructions in the order they are meant to be executed, unless there are specific commands to change the order (branches and jumps)? So, to keep it clear, the control flow of a program is the order each command will be executed, so this graph must represent the order in which the program can be executed.

Then, if there is a set of instructions without jumps or branches, we can agree that there is no change in the control flow of the program, right? If that's the case, we can also agree that we can group then together, and place them in a vertex. Each of these vertices we call a **basic block** of a program, and consist of a list of instructions that don't change the control flow of a program. The only exception is the last instruction of each basic block. It either terminates the program (a return instruction) or it changes the control flow (a jump or branch instruction).

But, wouldn't it be easier if we knew what is the first instruction of each basic block rather than the last instruction? Yes, but this is also easy to define, and we have a name for these instructions: **basic block headers**. We can define the basic block headers in our TAC rules in two ways:
- The first instruction of a program is a basic block header;
- The instruction right after a label is a basic block header.

So, the vertices are defined, but what about the edges? Well, now that we have the vertices, it's easy to see what the edges connect. First, note that the basic block that terminates a program don't have an out edge. As for the other basic blocks, they have branches or jumps to labels, and each of these labels refer to a basic block. Then, there will be an out edge to each label that the last instruction of the basic block goes to.

I would put an image here, but I'm not very used to Jekyll yet, then ASCII art is what I've got. Let's use the last example. I will separate the basic blocks in the TAC and replace the labels to the basic block names, and try to give some visualization of the CFG (that will very probably look terrible on small screens):

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

```
    bb0
    / \
  bb1  bb2
    \ /
    bb3
```

Yeah, that looks worse than I expected. Also, keep in mind that these lines are actually arrows, and go from up to down (in this case). I hope it's possible to understand the example.

### (Partial) Conclusion

So, I think I've covered the basic parts of Three Address Code and Control Flow Graphs in this post, and I hope it was understandable. And I really hope to have made it clear, since it's very important for a lot of things that I want to talk about here, so understanding these aspects is crucial.

I don't know in what frequency I'll be posting here, so don't have any expectations on future posts here. Maybe we'll see in a next post and, if you want to talk about the post, my email is on the [about]({{ "/about" | relative_url }}) page.

### References

The main material I used to make this post is from my [advisor's lectures on Static Program Analysis](https://homepages.dcc.ufmg.br/~fernando/classes/dcc888/ementa/).

If you want more material, you can check the [bibliography of the same course](https://homepages.dcc.ufmg.br/~fernando/classes/dcc888/biblio.html). 