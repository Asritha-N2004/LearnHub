import 'interview_question.dart';

final List<InterviewQuestion> pythonInterviewQuestions = buildInterviewQuestions(
  subject: 'Python Programming',
  idPrefix: 'python',
  basic: [
    questionDraft(r'''What is the difference between a list and a tuple?''', r'''A list is mutable, so its elements can be added, removed, or replaced; a tuple is immutable after creation. Tuples can be used as dictionary keys when all their members are hashable, whereas lists cannot.''', r'''Use a list for a changing shopping cart and a tuple for a fixed (latitude, longitude) pair.''', r'''Choose a collection based on whether the sequence is meant to change and whether it must be hashable.''', r'''List: mutable and unhashable. Tuple: immutable and conditionally hashable.''', code: r'''cart = ["tea"]
cart.append("bread")
point = (37.5, -122.2)
print(cart, point)''', output: r'''['tea', 'bread'] (37.5, -122.2)'''),
    questionDraft(r'''How do Python dictionaries store and retrieve values?''', r'''A dictionary maps unique, hashable keys to values and provides average-case constant-time lookup, insertion, and deletion. It preserves insertion order in modern Python, but that order should not be confused with sorting.''', r'''A user record can map "email" to an address and "active" to a Boolean.''', r'''Dictionaries are useful for keyed records, indexes, caches, and counting.''', r'''Keys must be hashable; lookup uses equality and hash; insertion order is preserved.''', code: r'''user = {"email": "ana@example.com", "active": True}
print(user["email"])''', output: r'''ana@example.com'''),
    questionDraft(r'''What does Python indentation signify?''', r'''Indentation defines suites, such as the bodies of functions, loops, and conditional statements. Consistent indentation is required because indentation is part of Python syntax rather than merely a formatting convention.''', r'''The indented print statement belongs to the if body only when the condition is true.''', r'''Indentation makes control flow visually explicit and avoids brace-related ambiguity.''', r'''Use consistent spaces; unexpected indentation changes block structure or raises IndentationError.''', code: r'''if ready:
    print("go")''', output: r'''go (when ready is true)'''),
    questionDraft(r'''What is the difference between == and is?''', r'''The == operator tests whether two objects compare equal by value, while is tests whether both references point to the exact same object. Use is for identity-sensitive checks such as `value is None`, not for comparing strings or numbers.''', r'''Two separately created lists can compare equal but are not the same object.''', r'''Identity checks are useful for sentinels and singleton values; equality is used for domain values.''', r'''`==` calls equality behavior; `is` checks identity; prefer `is None`.''', code: r'''a = [1]
b = [1]
print(a == b, a is b)''', output: r'''True False'''),
    questionDraft(r'''How do `if`, `elif`, and `else` select a branch?''', r'''Python evaluates conditions from top to bottom and executes the suite for the first true condition. The optional else suite runs only when no preceding condition is true.''', r'''A shipping fee can be free above a purchase threshold, reduced for members, and otherwise standard.''', r'''Use conditional branches to express mutually exclusive decisions clearly.''', r'''Only the first matching branch runs; conditions use truth-value testing.''', code: r'''total = 80
if total >= 100:
    fee = 0
elif total >= 50:
    fee = 5
else:
    fee = 10
print(fee)''', output: r'''5'''),
    questionDraft(r'''When should you use a for loop versus a while loop?''', r'''A for loop iterates over items from an iterable and is usually best when processing a collection or known sequence. A while loop repeats as long as a condition holds and is appropriate when the number of iterations depends on changing state.''', r'''Iterate over every CSV row with for; retry a network operation while attempts remain with while.''', r'''Choose the loop that communicates whether iteration is collection-driven or condition-driven.''', r'''For loops consume iterables; while loops recheck a condition; ensure while state advances.''', code: r'''for name in ["Mina", "Leo"]:
    print(name)''', output: r'''Mina
Leo'''),
    questionDraft(r'''What does a function return when it has no return statement?''', r'''A Python function without an explicit return statement returns None. A bare `return` also returns None, while a return expression passes that expression's value to the caller.''', r'''A logging function may print a message but produce None when called.''', r'''Understanding implicit return values prevents accidentally using side-effect-only functions as value producers.''', r'''Implicit result is None; print is not return; explicit return ends function execution.''', code: r'''def announce():
    print("ready")

result = announce()
print(result)''', output: r'''ready
None'''),
    questionDraft(r'''What is the difference between a parameter and an argument?''', r'''A parameter is a named variable in a function definition; an argument is the actual value supplied at a call site. Python supports positional, keyword, default, and variadic arguments.''', r'''In `def greet(name)`, name is a parameter; in `greet("Ravi")`, "Ravi" is an argument.''', r'''Precise terminology helps explain API signatures and call behavior.''', r'''Parameters appear in definitions; arguments appear in calls; keyword arguments bind by name.''', code: r'''def greet(name, prefix="Hi"):
    return f"{prefix}, {name}"
print(greet("Ravi", prefix="Hello"))''', output: r'''Hello, Ravi'''),
    questionDraft(r'''How does a list comprehension work?''', r'''A list comprehension constructs a list by evaluating an expression for each item in an iterable, optionally filtering items with a condition. It is concise, but nested or side-effect-heavy comprehensions are often less readable than ordinary loops.''', r'''Build the squares of only even integers from a range.''', r'''Comprehensions are useful for readable transformations and filtering of modest collections.''', r'''Expression precedes for clauses; optional if filters; result is a new list.''', code: r'''squares = [n * n for n in range(6) if n % 2 == 0]
print(squares)''', output: r'''[0, 4, 16]'''),
    questionDraft(r'''What is the difference between `append` and `extend`?''', r'''`append(x)` adds x as one element at the end of a list. `extend(iterable)` consumes an iterable and adds each yielded element separately.''', r'''Appending [2, 3] to [1] produces [1, [2, 3]], while extending produces [1, 2, 3].''', r'''Select the operation based on whether the argument is one item or a sequence of items to merge.''', r'''Append adds one object; extend iterates; both mutate the original list.''', code: r'''items = [1]
items.extend([2, 3])
items.append([4, 5])
print(items)''', output: r'''[1, 2, 3, [4, 5]]'''),
    questionDraft(r'''How do Python strings behave when modified?''', r'''Strings are immutable sequences of Unicode code points, so an operation that appears to modify a string creates a new string. Indexing and slicing produce characters or new string values without changing the original.''', r'''`word.upper()` returns a new uppercase string and leaves word unchanged.''', r'''Immutability enables safe sharing of string values and predictable APIs.''', r'''Immutable sequence; slicing creates a value; use join for efficient repeated concatenation.''', code: r'''word = "map"
upper = word.upper()
print(word, upper)''', output: r'''map MAP'''),
    questionDraft(r'''What is a Python module?''', r'''A module is a Python file whose definitions and statements can be imported by other code. Importing normally executes its top-level statements once per interpreter module cache, so modules should avoid surprising import-time side effects.''', r'''A `pricing.py` module can define a `discount()` function imported by a checkout service.''', r'''Modules divide applications into reusable and maintainable namespaces.''', r'''A .py file is commonly a module; imports bind names; guard script entry points with `if __name__ == "__main__"`.''', code: r'''# pricing.py
def discount(price, rate):
    return price * (1 - rate)''', output: r'''discount(100, 0.1) returns 90.0'''),
    questionDraft(r'''What is a Python package?''', r'''A package organizes related modules under a package namespace and can contain subpackages. Regular packages commonly include `__init__.py`; namespace packages can span locations and need not have that file.''', r'''A `store` package might contain `store.catalog` and `store.checkout` modules.''', r'''Packages support clear boundaries and scalable organization in larger codebases.''', r'''Packages group modules; `__init__.py` can define package initialization and exports; avoid circular imports.'''),
    questionDraft(r'''How does a `try`/`except` block handle errors?''', r'''Code in the try suite runs normally unless an exception occurs; a matching except suite then handles that exception. Catch specific exception types and allow unexpected failures to propagate rather than hiding defects with a blanket handler.''', r'''Catch ValueError when converting user-entered text to an integer, and display a validation message.''', r'''Exception handling separates expected recoverable failures from normal control flow.''', r'''Catch narrow types; `else` runs on success; `finally` runs during cleanup.''', code: r'''try:
    quantity = int("12x")
except ValueError:
    quantity = 0
print(quantity)''', output: r'''0'''),
    questionDraft(r'''What is the purpose of `None`?''', r'''None is Python's singleton object used to represent the absence of a value or an intentionally empty result. It is distinct from False, zero, and an empty collection, so test it with `is None`.''', r'''A database lookup can return None when no matching account exists.''', r'''None makes optional results explicit and helps distinguish missing data from valid false-like values.''', r'''Use `is None`; do not confuse with 0, False, or empty values; functions default to None.''', code: r'''result = None
print(result is None)''', output: r'''True'''),
    questionDraft(r'''What are mutable and immutable objects?''', r'''A mutable object can change its contents without changing its identity; lists and dictionaries are examples. Immutable objects such as integers, strings, and tuples cannot be changed in place, though a variable can be rebound to another object.''', r'''Appending to a list mutates it, while adding one to an integer binds a new integer result.''', r'''Mutability affects aliasing, function side effects, and whether values can be dictionary keys.''', r'''Mutability concerns object state; aliases share mutations; immutable members can be hashable.''', code: r'''values = [1]
alias = values
alias.append(2)
print(values)''', output: r'''[1, 2]'''),
    questionDraft(r'''What do `break` and `continue` do in loops?''', r'''`break` immediately exits the innermost enclosing loop, whereas `continue` skips the remainder of the current iteration and proceeds to the next one. Neither statement exits an enclosing function.''', r'''Skip blank input lines with continue and stop reading at a sentinel with break.''', r'''They express early loop decisions without deeply nested conditionals.''', r'''Break exits innermost loop; continue advances iteration; loop else is skipped by break.''', code: r'''for n in range(5):
    if n == 1:
        continue
    if n == 4:
        break
    print(n)''', output: r'''0
2
3'''),
    questionDraft(r'''How does `range` define a sequence of integers?''', r'''`range(start, stop, step)` represents integers beginning at start and proceeding by step, but never including stop. It is a compact, lazy sequence object rather than a prebuilt list.''', r'''`range(2, 8, 2)` represents 2, 4, and 6.''', r'''Use range for index-based loops or predictable integer iteration without allocating a list.''', r'''Stop is exclusive; step cannot be zero; range supports membership and indexing.''', code: r'''print(list(range(2, 8, 2)))''', output: r'''[2, 4, 6]'''),
    questionDraft(r'''What is a set and when is it useful?''', r'''A set is an unordered collection of distinct hashable elements that supports efficient membership tests and set algebra. It removes duplicates, but it does not provide positional indexing.''', r'''Convert a list of tags to a set to find unique tags or intersect tags with an allowed set.''', r'''Sets support deduplication, membership filters, and overlap analysis.''', r'''Unique elements; hashable members; union, intersection, difference; no stable positional access.''', code: r'''tags = {"python", "sql", "python"}
print(sorted(tags))''', output: r'''['python', 'sql']'''),
    questionDraft(r'''How does a default argument work in a function definition?''', r'''A default value is used when a caller omits that argument, and it is evaluated once when the function is defined. Mutable defaults therefore persist across calls and should usually be replaced by a None sentinel initialized inside the function.''', r'''Use `items=None` and create a fresh list inside each call instead of defaulting to `[]`.''', r'''Defaults make APIs convenient while safe sentinel patterns prevent cross-call state leaks.''', r'''Defaults evaluated once; beware mutable defaults; required parameters precede defaulted positional parameters.''', code: r'''def collect(value, items=None):
    if items is None:
        items = []
    items.append(value)
    return items
print(collect(1), collect(2))''', output: r'''[1] [2]'''),
  ],
  intermediate: [
    questionDraft(r'''Why does a mutable default argument retain state between calls?''', r'''Python evaluates a function's default expressions once, when the def statement executes, and stores the resulting objects on the function. A mutable default is therefore shared by calls that omit the argument; use a None sentinel and allocate a new object per call.''', r'''A function with `cache={}` may unexpectedly return entries left by an earlier call.''', r'''This matters in request handlers and helpers expected to have isolated per-call state.''', r'''Defaults live on function; mutable object is shared; initialize inside when freshness is needed.''', code: r'''def add(value, items=None):
    if items is None:
        items = []
    items.append(value)
    return items
print(add("a"), add("b"))''', output: r'''['a'] ['b']'''),
    questionDraft(r'''What is the difference between an iterable and an iterator?''', r'''An iterable can produce an iterator, usually through `iter()`, while an iterator implements `__next__()` and yields values one at a time until StopIteration. Many iterables can create multiple independent iterators, but an iterator is generally a stateful, consumable stream.''', r'''A list is reusable as an iterable; `iter(list)` is an iterator whose next call advances its position.''', r'''Understanding the protocol helps when processing large files and generator pipelines.''', r'''Iterable provides `__iter__`; iterator provides `__next__`; iterators are often one-pass.''', code: r'''it = iter([4, 5])
print(next(it), next(it))''', output: r'''4 5'''),
    questionDraft(r'''How do generators differ from materialized lists?''', r'''A generator yields values on demand and retains execution state between yields, rather than storing every result at once. This can reduce memory use for large or unbounded streams, but generators are usually consumed only once.''', r'''A generator can read millions of log lines and yield only those matching a filter.''', r'''Use generators for streaming transformations and memory-conscious pipelines.''', r'''`yield` suspends execution; lazy evaluation; one-pass unless regenerated.''', code: r'''def squares(limit):
    for n in range(limit):
        yield n * n
print(list(squares(4)))''', output: r'''[0, 1, 4, 9]'''),
    questionDraft(r'''What is a decorator in Python?''', r'''A decorator is a callable that takes a function or class and returns a replacement, commonly used with `@decorator` syntax. It can wrap behavior such as timing or authorization while preserving the original callable through `functools.wraps`.''', r'''A retry decorator can apply a shared retry policy to several network functions.''', r'''Decorators factor cross-cutting behavior out of function bodies.''', r'''`@d` is rebinding to `d(function)`; wrappers should preserve metadata; order matters.''', code: r'''from functools import wraps
def trace(fn):
    @wraps(fn)
    def wrapped(*args, **kwargs):
        print("calling", fn.__name__)
        return fn(*args, **kwargs)
    return wrapped
@trace
def total(a, b):
    return a + b
print(total(2, 3))''', output: r'''calling total
5'''),
    questionDraft(r'''What does a context manager guarantee?''', r'''A context manager manages setup and cleanup around a block, using `__enter__`/`__exit__` or a generator-based implementation. Its exit logic runs when the block finishes, including when an exception is raised, allowing resources to be released reliably.''', r'''`with open(path) as file` closes the file after reading even if processing raises.''', r'''Use context managers for files, locks, transactions, and other scoped resources.''', r'''`with` calls enter and exit; exit can suppress exceptions; cleanup is deterministic.''', code: r'''from io import StringIO
with StringIO("hello") as stream:
    text = stream.read()
print(text, stream.closed)''', output: r'''hello True'''),
    questionDraft(r'''How do shallow and deep copies differ?''', r'''A shallow copy creates a new outer container but keeps references to the original nested objects. A deep copy recursively copies nested contents where possible, though custom objects may define special copying behavior.''', r'''Copying a list of dictionaries shallowly still shares each dictionary with the source.''', r'''Copying strategy matters when editing nested configuration or request data independently.''', r'''Shallow copy duplicates outer container; deepcopy recursively copies; copying may be expensive or inappropriate for resources.''', code: r'''import copy
source = [[1]]
shallow = copy.copy(source)
deep = copy.deepcopy(source)
shallow[0].append(2)
print(source, deep)''', output: r'''[[1, 2]] [[1]]'''),
    questionDraft(r'''What are `*args` and `**kwargs` used for?''', r'''In a function definition, `*args` collects additional positional arguments into a tuple and `**kwargs` collects extra keyword arguments into a dictionary. They are also used in calls to unpack an iterable or mapping into arguments.''', r'''A logging wrapper can accept arbitrary arguments and forward them to the wrapped function.''', r'''Variadic parameters support adapters, decorators, and flexible APIs when used with clear contracts.''', r'''`*args` tuple; `**kwargs` dict; call unpacking; named parameters should remain explicit when practical.''', code: r'''def show(first, *args, **kwargs):
    print(first, args, kwargs)
show("x", 2, 3, mode="fast")''', output: r'''x (2, 3) {'mode': 'fast'}'''),
    questionDraft(r'''What is a closure and what does `nonlocal` change?''', r'''A closure is a function that retains access to variables from its enclosing lexical scope after that scope has returned. `nonlocal` lets an inner function rebind a variable in the nearest enclosing function scope rather than creating a local name.''', r'''A counter factory can return a function that remembers and increments its own count.''', r'''Closures implement small stateful callbacks and function factories without a class.''', r'''Lexical capture; `nonlocal` rebinds enclosing function variable; `global` refers to module scope.''', code: r'''def counter():
    count = 0
    def next_value():
        nonlocal count
        count += 1
        return count
    return next_value
next_id = counter()
print(next_id(), next_id())''', output: r'''1 2'''),
    questionDraft(r'''How does Python's method resolution order work?''', r'''Python uses a class's method resolution order (MRO) to determine where attribute lookup searches across base classes. Its C3 linearization preserves local precedence and a consistent monotonic order; `super()` follows that MRO rather than simply calling a named parent.''', r'''In a diamond hierarchy, cooperative methods use `super()` so each class in the MRO participates once.''', r'''MRO reasoning is essential when composing mixins and multiple inheritance.''', r'''Inspect `Class.__mro__`; C3 linearization; `super()` is cooperative and MRO-aware.''', code: r'''class A: pass
class B(A): pass
class C(A): pass
class D(B, C): pass
print([cls.__name__ for cls in D.__mro__])''', output: r'''['D', 'B', 'C', 'A', 'object']'''),
    questionDraft(r'''When should a class use `@classmethod` or `@staticmethod`?''', r'''A class method receives the class as its first argument and is useful for alternate constructors or behavior that depends on the subclass. A static method receives no implicit instance or class and is a namespaced utility; ordinary instance methods receive the instance.''', r'''`from_json` can be a class method that constructs the concrete subclass from decoded data.''', r'''Choose the method type according to the state and polymorphic context the operation needs.''', r'''Instance method gets self; class method gets cls; static method gets neither implicitly.''', code: r'''class Point:
    def __init__(self, x, y):
        self.x, self.y = x, y
    @classmethod
    def origin(cls):
        return cls(0, 0)
    @staticmethod
    def valid(x, y):
        return x >= 0 and y >= 0
print(Point.origin().x, Point.valid(1, 2))''', output: r'''0 True'''),
    questionDraft(r'''What are properties used for in a class?''', r'''A property exposes attribute-style access while routing reads, writes, or deletes through methods. It allows validation or a computed value without changing the public access syntax, and can replace a simple attribute while preserving callers.''', r'''A temperature property can reject values below absolute zero when assigned.''', r'''Properties encapsulate invariants and computed attributes in domain models.''', r'''`@property` getter; setter via `@x.setter`; avoid surprising expensive or side-effectful accessors.''', code: r'''class Celsius:
    def __init__(self, value):
        self.value = value
    @property
    def value(self):
        return self._value
    @value.setter
    def value(self, value):
        if value < -273.15:
            raise ValueError("below absolute zero")
        self._value = value
print(Celsius(20).value)''', output: r'''20'''),
    questionDraft(r'''How do Python exceptions form an inheritance hierarchy?''', r'''Exceptions are classes derived from BaseException, with ordinary application errors generally deriving from Exception. Catching a base class handles its subclasses, so handlers should target the narrowest meaningful exception and use exception chaining when translating failures.''', r'''Translate a low-level ValueError into a domain-specific InvalidDate while preserving its cause.''', r'''A deliberate exception hierarchy makes error handling precise at module and API boundaries.''', r'''Catch Exception subclasses, not BaseException for routine recovery; preserve causes with `raise ... from ...`.''', code: r'''try:
    int("nope")
except ValueError as error:
    raise RuntimeError("invalid input") from error'''),
    questionDraft(r'''What is the difference between `__str__` and `__repr__`?''', r'''`__str__` aims to provide a readable, user-facing representation, while `__repr__` aims to provide an unambiguous developer-facing representation and ideally a reconstructible expression. `str()` falls back to `repr()` when no string method is defined.''', r'''A Money object may display as `$12.50` to users but `Money(1250, "USD")` in debugging.''', r'''Good representations improve logs, debugging, and interactive inspection.''', r'''`str` is presentation-oriented; `repr` is diagnostic; implement repr for useful object inspection.''', code: r'''class Item:
    def __repr__(self):
        return "Item(code='A7')"
print(repr(Item()))''', output: r'''Item(code='A7')'''),
    questionDraft(r'''How do `zip` and `zip_longest` differ?''', r'''Built-in `zip` pairs items from iterables and stops as soon as the shortest iterable is exhausted. `itertools.zip_longest` continues until the longest is exhausted, filling missing positions with a configurable sentinel.''', r'''Pair employee names with IDs using zip when lengths must match; use zip_longest to expose missing entries.''', r'''Use the stopping behavior deliberately so mismatched data is not silently discarded.''', r'''Lazy iterator; shortest input controls built-in zip; zip_longest provides fillvalue.''', code: r'''from itertools import zip_longest
print(list(zip_longest(["A", "B"], [7], fillvalue=None)))''', output: r'''[('A', 7), ('B', None)]'''),
    questionDraft(r'''What is the benefit of a `dataclass`?''', r'''The dataclasses module can generate common methods such as `__init__`, `__repr__`, and equality based on annotated fields. It reduces boilerplate for data-centric classes, while validation and domain behavior can still be implemented explicitly.''', r'''A Point dataclass can provide construction and value equality without hand-writing both methods.''', r'''Dataclasses are useful for records, configuration objects, and structured return values.''', r'''Annotations define fields; `default_factory` for mutable defaults; frozen option prevents normal reassignment.''', code: r'''from dataclasses import dataclass
@dataclass
class Point:
    x: int
    y: int
print(Point(2, 3) == Point(2, 3))''', output: r'''True'''),
    questionDraft(r'''How can type hints help without enforcing runtime types?''', r'''Type annotations document intended interfaces and enable static analyzers, IDE completion, and refactoring tools. Python does not generally enforce annotations at runtime, so validation at external boundaries still requires explicit checks or a validation library.''', r'''Annotate a function as accepting `list[int]` and returning `float` to make its contract inspectable.''', r'''Hints improve maintainability and catch many mistakes before execution in typed codebases.''', r'''Annotations are metadata; static checking is external; runtime validation is separate.''', code: r'''def average(values: list[float]) -> float:
    return sum(values) / len(values)
print(average([2.0, 4.0]))''', output: r'''3.0'''),
    questionDraft(r'''How does `async`/`await` support concurrent I/O?''', r'''An async function returns a coroutine, and `await` suspends that coroutine while an awaitable is not ready so an event loop can run other tasks. It improves concurrency for I/O-bound work but does not automatically make CPU-bound work parallel.''', r'''An async client can await several HTTP requests concurrently with `asyncio.gather`.''', r'''Use async APIs for high-concurrency network or file operations when libraries support them.''', r'''Coroutine function declared async; await yields control; CPU-heavy work needs processes or other offloading.''', code: r'''import asyncio
async def fetch():
    await asyncio.sleep(0)
    return "done"
print(asyncio.run(fetch()))''', output: r'''done'''),
    questionDraft(r'''How should a Python program manage files safely?''', r'''Use `with open(...)` so file closure happens reliably, and specify encoding for text files to avoid platform-dependent decoding. Select text or binary mode according to the content and handle expected I/O exceptions at an appropriate boundary.''', r'''Read a UTF-8 configuration file in text mode and let the context manager close it.''', r'''Safe file handling prevents descriptor leaks and inconsistent text decoding.''', r'''Context manager closes file; specify encoding; binary mode returns bytes.''', code: r'''from io import StringIO
with StringIO("one\ntwo") as file:
    lines = file.read().splitlines()
print(lines)''', output: r'''['one', 'two']'''),
    questionDraft(r'''What is the purpose of `collections.Counter`?''', r'''Counter is a dict subclass designed to count hashable objects, with convenient construction from iterables and operations such as retrieving most common items. It communicates counting intent more clearly than a hand-written dictionary update loop.''', r'''Count word frequencies in tokenized documents to identify common terms.''', r'''Use Counter in analytics, frequency tables, and multiset-like comparisons.''', r'''Counts hashable items; missing keys read as zero; `most_common` ranks frequencies.''', code: r'''from collections import Counter
print(Counter("banana").most_common(2))''', output: r'''[('a', 3), ('n', 2)]'''),
    questionDraft(r'''How does `functools.lru_cache` affect a function?''', r'''`lru_cache` memoizes calls by argument values and returns a stored result for repeated hashable argument combinations. It is suitable for deterministic functions, but cached results can become stale when external state changes and the cache consumes memory until bounded or cleared.''', r'''Cache recursive Fibonacci results to avoid recalculating the same subproblems.''', r'''Memoization speeds repeated pure computations; choose a size limit or clear policy where needed.''', r'''Arguments must be hashable; results are reused; side effects and changing inputs make caching unsafe.''', code: r'''from functools import lru_cache
@lru_cache(maxsize=None)
def fib(n):
    return n if n < 2 else fib(n - 1) + fib(n - 2)
print(fib(8))''', output: r'''21'''),
  ],
  advanced: [
    questionDraft(r'''How does Python's descriptor protocol control attribute access?''', r'''An object defining `__get__`, `__set__`, or `__delete__` is a descriptor, and descriptors customize attribute access when stored on a class. Data descriptors take precedence over an instance dictionary, enabling properties and ORM fields to enforce behavior.''', r'''An ORM column descriptor can validate assigned values and load a field when it is accessed.''', r'''Descriptors underpin properties, methods, and reusable attribute-level frameworks.''', r'''Data descriptor defines set/delete; non-data may define only get; lookup precedence affects shadowing.''', code: r'''class Positive:
    def __set_name__(self, owner, name):
        self.name = "_" + name
    def __get__(self, obj, owner=None):
        return getattr(obj, self.name) if obj else self
    def __set__(self, obj, value):
        if value <= 0:
            raise ValueError("must be positive")
        setattr(obj, self.name, value)
class Stock:
    quantity = Positive()
s = Stock()
s.quantity = 3
print(s.quantity)''', output: r'''3'''),
    questionDraft(r'''What is metaclass customization used for?''', r'''A metaclass is the class of a class and can customize class creation, typically by deriving from `type` and overriding `__new__` or `__init__`. It is powerful but adds complexity, so class decorators or `__init_subclass__` are often simpler choices.''', r'''A framework metaclass can validate that every plugin class declares a unique registry name.''', r'''Metaclasses are appropriate when class-definition-time policy must be applied consistently across a hierarchy.''', r'''Metaclass creates classes; `type` is the default; prefer simpler hooks where sufficient.''', code: r'''class RequireCode(type):
    def __new__(mcls, name, bases, namespace):
        if name != "Base" and "code" not in namespace:
            raise TypeError("code required")
        return super().__new__(mcls, name, bases, namespace)
class Base(metaclass=RequireCode):
    pass
class Plugin(Base):
    code = "P1"
print(Plugin.code)''', output: r'''P1'''),
    questionDraft(r'''What does the Global Interpreter Lock imply for CPU-bound Python code?''', r'''In standard GIL-enabled CPython, threads do not usually execute Python bytecode simultaneously within one interpreter, so CPU-bound pure-Python threads often fail to use multiple cores. A process pool can provide parallel execution but adds serialization, startup, and memory costs; other Python implementations and free-threaded builds may differ.''', r'''Parallelize independent image calculations in processes, then compare total wall time including data transfer.''', r'''Benchmark workload; distinguish I/O concurrency from CPU parallelism; account for runtime build and process overhead.''', r'''GIL is CPython-specific behavior; process parallelism has costs; native extensions may release GIL.'''),
    questionDraft(r'''How do you design a reliable asynchronous task pipeline?''', r'''Use structured task management so child tasks are awaited or cancelled when their scope ends, and propagate errors rather than leaving orphaned work. Apply bounded concurrency and timeouts to control resource use, and use an async-compatible client throughout the call chain.''', r'''A service can fetch many URLs using a semaphore to cap simultaneous requests and cancel remaining tasks after a fatal failure.''', r'''A bounded async pipeline protects services from overload while preserving predictable cleanup.''', r'''Await all created tasks; bound concurrency; set deadlines; propagate cancellation and exceptions.''', code: r'''import asyncio
async def run():
    limit = asyncio.Semaphore(2)
    async def work(n):
        async with limit:
            await asyncio.sleep(0)
            return n * 2
    return await asyncio.gather(*(work(n) for n in range(4)))
print(asyncio.run(run()))''', output: r'''[0, 2, 4, 6]'''),
    questionDraft(r'''What is the difference between a coroutine, a task, and a future?''', r'''A coroutine is the awaitable computation produced by calling an async function; a Task schedules a coroutine to run on an event loop. A Future represents a result that may become available later and is the lower-level mechanism Tasks use to expose completion.''', r'''Create tasks for independent API requests and await their results collectively with gather.''', r'''The distinctions clarify scheduling, cancellation, and result ownership in async systems.''', r'''Coroutine is computation; Task schedules coroutine; Future is eventual result; tasks must be awaited or managed.''', code: r'''import asyncio
async def value():
    return 9
async def main():
    task = asyncio.create_task(value())
    return await task
print(asyncio.run(main()))''', output: r'''9'''),
    questionDraft(r'''How can `contextvars` isolate request-local state in async code?''', r'''Context variables provide context-local values that follow asynchronous task execution without relying on process-global mutable state. They are useful for correlation IDs and request metadata, but should not replace explicit parameters for core business inputs.''', r'''Set a trace ID for each incoming request so concurrent coroutines log the correct identifier.''', r'''Context-local metadata avoids cross-request leakage in asynchronous applications.''', r'''Use ContextVar; task contexts are isolated; reset tokens after scoped overrides.''', code: r'''from contextvars import ContextVar
request_id = ContextVar("request_id", default="none")
token = request_id.set("req-7")
print(request_id.get())
request_id.reset(token)''', output: r'''req-7'''),
    questionDraft(r'''What problem does `__slots__` solve, and what trade-offs does it have?''', r'''`__slots__` declares a fixed set of instance attributes and can avoid a per-instance `__dict__`, reducing memory for large numbers of small objects. It constrains dynamic attributes and complicates inheritance, weak references, and some serialization patterns.''', r'''A memory-intensive application with millions of small immutable coordinate objects may benefit from slots after measurement.''', r'''Use slots only when memory profiling justifies restrictions; dataclasses also support slots.''', r'''Fixed attributes; possible memory savings; no arbitrary attributes; inheritance requires care.''', code: r'''class Pixel:
    __slots__ = ("x", "y")
    def __init__(self, x, y):
        self.x, self.y = x, y
p = Pixel(2, 5)
print(p.x)''', output: r'''2'''),
    questionDraft(r'''How should a Python API handle resource cleanup when exceptions occur?''', r'''Encapsulate acquisition and release in a context manager or `try/finally` so cleanup runs on both success and failure. For multiple resources, nested context managers or `contextlib.ExitStack` provide reliable reverse-order cleanup.''', r'''An upload pipeline opens a file and a temporary directory, then guarantees both are closed or removed if parsing fails.''', r'''Deterministic cleanup protects file descriptors, locks, temporary data, and transactions.''', r'''Acquire within managed scope; cleanup in finally/exit; preserve original exceptions where possible.''', code: r'''from contextlib import ExitStack
from io import StringIO
with ExitStack() as stack:
    first = stack.enter_context(StringIO("a"))
    second = stack.enter_context(StringIO("b"))
    print(first.read() + second.read())''', output: r'''ab'''),
    questionDraft(r'''What are the security risks of deserializing untrusted Python data with pickle?''', r'''Pickle deserialization can execute arbitrary code through crafted object reconstruction, so it must not be used on untrusted or unauthenticated input. Use a data-only format such as JSON with schema validation, or a carefully constrained format designed for the required types.''', r'''An API should reject uploaded pickle payloads and accept validated JSON records instead.''', r'''Treat pickle as trusted-code serialization only; validate input format and authentication separately.''', r'''Unpickling can execute code; JSON is data-only but still needs validation; never trust attacker-controlled pickle.'''),
    questionDraft(r'''How do reference counting and cyclic garbage collection work in CPython?''', r'''CPython primarily reclaims objects when their reference count reaches zero, and supplements that mechanism with a cyclic garbage collector that can detect unreachable reference cycles. Finalization timing and garbage collection are implementation details, so resource cleanup should rely on context managers rather than object destruction.''', r'''Two objects that reference each other can remain allocated after the rest of the program drops its references until cyclic collection finds them unreachable.''', r'''Understanding memory reclamation helps diagnose leaks and reinforces explicit management for files, sockets, and locks.''', r'''CPython reference counts plus cycle detector; collection is not a resource-lifetime guarantee; use context managers.'''),
  ],
);
