# BigTest

BigTest expresses and performs _very long-running_ batches of tests that
exercise services on the Internet Computer.

To use BigTest, the test author expresses each test script as a
program written in a domain specific language (DSL).

For Motoko programmers, BigTest provides a `Batch` class to build
flexible test actors that test a specific service extensively, but
without running out of gas, or out of time.

BigTest implements this DSL in Motoko using standard PL implementation
techniques that permit the DSL evaluation to implicitly **suspend**
and **resume** around each remote Internet Computer service call.

## BigTest expression language

The BigTest expression language is general enough for many kinds of tests:

 - **Standard PL features**: iteration, let-binding, primitive data
 - **Calls** to the service in question (e.g., `put` and `get` on `BigMap`)
 - **Buffers** and generators for test input and output
 - **Equivalence** checks for all test data output
 - **Assertions** whose failure signals a testing failure
 - **Labels** for human-readable reports, documentation and logs

## Why?

Today, we can use shell scripts to invoke `dfx canister call` many times.

**Q** _Why not use a shell script to create long-running tests?_

This is certainly possible, and we do this today.  Eventually,
however, **programs that test canisters should _themselves_ be
programmed as canisters**, not shell scripts running on traditional CI
systems.

To reach this goal, we need a new test-scripting language, as those
shell scripts do not run on the Internet Computer, and probably will
not soon.  Unlike shell scripts, the BigTest language does not assume
a filesystem, or any ambient UNIX system.  Rather, it only
assumes a Motoko runtime environment, provided by the IC itself.

With BigTest, we can:

- Host test logic on the Internet Computer itself,
- Ask the test canister what script its running, what progress there is, etc
- Reuse the same dead simple shell script (one single loop, with one call)
- [(Eventually,) pre-check scripts for sanity, errors, etc](https://arxiv.org/pdf/1608.06012.pdf)


**Q:** _Why not write testing canisters directly in Rust, or in Motoko?_

This works fine for small tests that exercise the IC minimally, with a
small number of service calls.  Let's call these "small batch tests".

But how do we relate these small batches, or systematically combine
them into large ones?

To ask it another way, how do we _systematically decompose a big test
batch_ into many very small ones?

To solve this problem, we need techniques that _stream_ the behavior
of the batch test, and keep it "live" across many separate activating
ingress calls.  This way, a big batch can be decomposed (via
streaming) into many small batches.

This is precisely the problem solved by the BigTest DSL evaluator.

Notably, it's also solved by languages that implement an `async`
abstraction.  More below.


### Aside: Static versus dynamic PL techniques

Why even implement this new language if we already have Rust and Motoko?

In terms of language design, Motoko programs and BigTest programs are
attacking similar problems.

For example, these two tests are very similar (intentionally):

 - Motoko-based `PutGet` test for BigMap ([`test/PutGet.mo`](https://github.com/dfinity/motoko-bigmap/blob/master/test/PutGet.mo))
 - `PutGet` as a BigTest test expression ([`test/BigTestPutGet.mo`](https://github.com/dfinity/motoko-bigmap/blob/master/test/BigTestPutGet.mo))

In both settings, interacting with the Internet Computer interrupts
ordinary control flow constructs, like simple loops, and the language
uses techniques to hide this interruption from programmers, who do not
wish to express it directly in their source programs. In sum, both
languages express programs whose IC service calls require saving and
restoring a surrounding calling context.

Of course, the BigTest system is itself expressed as a Motoko program.

Unlike _Motoko programs_, _BigTest programs are Motoko data_, and can
be sent in a message or received as a response.

Further, unlike a Rust or Motoko program, a BigTest program can be
inspected and manipulated dynamically in a totally straightforward
way, permitting tests to (potentially) be viewed, changed or extended
while they are running.

Stepping back, these benefits are merely those of dynamic PL
techniques over static ones.

BigTest would also benefit from additional (currently missing) static
techniques, such as a type system for doing sanity checks.

[Eventually, enough static checks would render BigTest more like Motoko
and Rust, which is not the goal.](https://arxiv.org/pdf/1608.06012.pdf)
