# 2026-07-22  divmod_plots.py

from __future__ import annotations
from collections.abc import Callable
from dataclasses import dataclass
from fractions import Fraction
from functools import wraps
from itertools import chain, groupby, product

import math
import operator as op

from termcolor import colored
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import numpy as np

# -------- 编辑时和运行时检查 --------

type Rational = int | Fraction
rational_types_tuple = (int, Fraction)
type UnaryClosure[T] = Callable[[T], T]
type BinaryClosure[T] = Callable[[T, T], T]
type UnaryPred[T] = Callable[[T], bool]
type UnaryPredNonStrict[T] = Callable[[T], object]

def return_value_satisfies_conditional[R, **P](
        conditional_cond: Callable[P, UnaryPredNonStrict[R]],
        ) -> UnaryClosure[Callable[P, R]]:
    def wrapper(func: Callable[P, R]) -> Callable[P, R]:
        @wraps(func)
        def wrapped(*args: P.args, **kwargs: P.kwargs) -> R:
            res = func(*args, **kwargs)
            assert conditional_cond(*args, **kwargs)(res)
            return res
        return wrapped
    return wrapper

def return_value_satisfies[R, **P](
        cond: UnaryPredNonStrict[R],
        ) -> UnaryClosure[Callable[P, R]]:
    def conditional_cond(*_1: P.args, **_2: P.kwargs) -> UnaryPredNonStrict[R]:
        _ = _1
        _ = _2
        return cond
    return return_value_satisfies_conditional(conditional_cond)

# TODO:
# 试图加入有默认值的 equiv 参数时推导总是出错。
# 不加入 equiv 参数时提示“TypeVar "R" 在泛型函数签名中仅显示一次 请改用 "object"”，
# 然而将带参数别名 UnaryClosure 展开后其实就不报错了。
def assert_same_behavior_as[R, S, **P](
        f: Callable[P, S],
        ) -> UnaryClosure[Callable[P, R]]:  # pyright: ignore[reportInvalidTypeVarUse]
    def wrapper(func: Callable[P, R]) -> Callable[P, R]:
        @wraps(func)
        def wrapped(*args: P.args, **kwargs: P.kwargs) -> R:
            res = func(*args, **kwargs)
            assert res == f(*args, **kwargs)
            return res
        return wrapped
    return wrapper

# -------- 通用 --------

def identity[T](obj: T) -> T:
    return obj

# -------- 有理数相关运算 --------

def div_exact(a: Rational, n: Rational) -> Rational:
    return Fraction(a, n)

def exact_wrapper_math_floor(a: Rational) -> Rational:
    return math.floor(a)

def exact_wrapper_math_ceil(a: Rational) -> Rational:
    return math.ceil(a)

def exact_wrapper_math_trunc(a: Rational) -> Rational:
    return math.trunc(a)

def exact_wrapper_builtin_round(a: Rational) -> Rational:
    return round(a)

def sgn(a: Rational) -> Rational:
    return 0 if a == 0 else div_exact(a, abs(a))

def split_sgn(a: Rational) -> tuple[Rational, Rational]:
    return sgn(a), abs(a)

HALF = div_exact(1, 2)

# -------- 谓词 --------

def is_integer(a: Rational) -> bool:
    return a.is_integer()

def is_tie(a: Rational) -> bool:
    return is_integer(a + HALF)

def is_even(a: Rational) -> bool:
    return a % 2 == 0

def is_odd(a: Rational) -> bool:
    return a % 2 == 1

def is_nonnegative(a: Rational) -> bool:
    return a >= 0

def is_positive(a: Rational) -> bool:
    return a > 0

def is_nonpositive(a: Rational) -> bool:
    return a <= 0

def is_negative(a: Rational) -> bool:
    return a < 0

# -------- 带余除法策略 --------

@dataclass(frozen=True)
class DivModAlgorithm(object):
    @dataclass(frozen=True)
    class DivFunction(object):
        func: BinaryClosure[Rational]
        def __call__(self, a: Rational, n: Rational) -> Rational:
            return self.func(a, n)
    @dataclass(frozen=True)
    class ModFunction(object):
        func: BinaryClosure[Rational]
        def __call__(self, a: Rational, n: Rational) -> Rational:
            return self.func(a, n)

    func: DivFunction | ModFunction
    name: str

    @classmethod
    def from_div(cls, div: BinaryClosure[Rational], name: str) -> DivModAlgorithm:
        return cls(cls.DivFunction(div), name)

    @classmethod
    def from_mod(cls, mod: BinaryClosure[Rational], name: str) -> DivModAlgorithm:
        return cls(cls.ModFunction(mod), name)

    @staticmethod
    def _check_qr_res(qr: tuple[Rational, Rational]) -> bool:
        q, _ = qr
        return is_integer(q)

    @staticmethod
    def _get_r(a: Rational, n: Rational, q: Rational) -> Rational:
        return a - q * n

    @staticmethod
    def _get_q(a: Rational, n: Rational, r: Rational) -> Rational:
        return div_exact(a - r, n)

    @return_value_satisfies(_check_qr_res)
    def divmod(self, a: Rational, n: Rational) -> tuple[Rational, Rational]:
        if isinstance(self.func, DivModAlgorithm.DivFunction):
            q = self.func(a, n)
            r = DivModAlgorithm._get_r(a, n, q)
            return (q, r)
        r = self.func(a, n)
        q = DivModAlgorithm._get_q(a, n, r)
        return (q, r)

    @return_value_satisfies(is_integer)
    def div(self, a: Rational, n: Rational) -> Rational:
        if isinstance(self.func, DivModAlgorithm.DivFunction):
            return self.func(a, n)
        return DivModAlgorithm._get_q(a, n, self.func(a, n))

    def mod(self, a: Rational, n: Rational) -> Rational:
        if isinstance(self.func, DivModAlgorithm.ModFunction):
            return self.func(a, n)
        return DivModAlgorithm._get_r(a, n, self.func(a, n))

    def version_z(self) -> DivModAlgorithm:
        @return_value_satisfies(is_integer)
        def div(a: Rational, n: Rational) -> Rational:
            sa, absa = split_sgn(a)
            return sa * self.div(absa, n)
        return DivModAlgorithm.from_div(div, f'{self.name}_z')

    def version_n(self) -> DivModAlgorithm:
        @return_value_satisfies(is_integer)
        def div(a: Rational, n: Rational) -> Rational:
            sn, absn = split_sgn(n)
            return sn * self.div(a, absn)
        return DivModAlgorithm.from_div(div, f'{self.name}_n')

    def version_zn(self) -> DivModAlgorithm:
        @return_value_satisfies(is_integer)
        def div(a: Rational, n: Rational) -> Rational:
            sa, absa = split_sgn(a)
            sn, absn = split_sgn(n)
            return sa * sn * self.div(absa, absn)
        return DivModAlgorithm.from_div(div, f'{self.name}_zn')

def make_div_from_rounding(round: UnaryClosure[Rational]) -> BinaryClosure[Rational]:
    @return_value_satisfies(is_integer)
    def div(a: Rational, n: Rational) -> Rational:
        return round(div_exact(a, n))
    return div

def make_mod_from_interval_maker(maker: Callable[[Rational], FiniteRationalInterval]) -> BinaryClosure[Rational]:
    def interval_in_range(n: Rational, /) -> UnaryPred[FiniteRationalInterval]:
        def check(retval: FiniteRationalInterval, /) -> bool:
            return retval.is_half_open() and retval in FiniteRationalInterval(-abs(n), abs(n), False, False)
        return check
    maker = return_value_satisfies_conditional(interval_in_range)(maker)

    # TODO: 目前 `mod` 函数及其装饰器所需要的函数都要造区间。
    def remainder_in_range(_: Rational, n: Rational, /) -> UnaryPred[Rational]:
        interval = maker(n)
        def check(x: Rational, /) -> bool:
            return x in interval
        return check
    @return_value_satisfies_conditional(remainder_in_range)
    def mod(a: Rational, n: Rational) -> Rational:
        interval = maker(n)
        res = a % n
        return res if res in interval else res - n
    return mod

# -------- 各种 round 方式 --------

# IEEE 754 命名
@assert_same_behavior_as(exact_wrapper_math_floor)
def round_to_integral_toward_negative(a: Rational) -> Rational:
    if is_integer(a):
        return a
    return a.numerator // a.denominator

# IEEE 754 命名
@assert_same_behavior_as(exact_wrapper_math_ceil)
def round_to_integral_toward_positive(a: Rational) -> Rational:
    if is_integer(a):
        return a
    return (a.numerator + a.denominator - 1) // a.denominator

# IEEE 754 命名
@assert_same_behavior_as(exact_wrapper_math_trunc)
def round_to_integral_toward_zero(a: Rational) -> Rational:
    if is_nonnegative(a):
        return round_to_integral_toward_negative(a)
    return round_to_integral_toward_positive(a)

def round_to_integral_toward_away(a: Rational) -> Rational:
    if is_nonnegative(a):
        return round_to_integral_toward_positive(a)
    return round_to_integral_toward_negative(a)

def another_round_to_integral_ties_to_negative(a: Rational) -> Rational:
    return round_to_integral_toward_positive(a - HALF)

@assert_same_behavior_as(another_round_to_integral_ties_to_negative)
def round_to_integral_ties_to_negative(a: Rational) -> Rational:
    if not is_tie(a):
        return round(a)
    return round_to_integral_toward_negative(a)

def another_round_to_integral_ties_to_positive(a: Rational) -> Rational:
    return round_to_integral_toward_negative(a + HALF)

@assert_same_behavior_as(another_round_to_integral_ties_to_positive)
def round_to_integral_ties_to_positive(a: Rational) -> Rational:
    if not is_tie(a):
        return round(a)
    return round_to_integral_toward_positive(a)

def round_to_integral_ties_to_zero(a: Rational) -> Rational:
    if not is_tie(a):
        return round(a)
    return round_to_integral_toward_zero(a)

# IEEE 754 命名
def round_to_integral_ties_to_away(a: Rational) -> Rational:
    if not is_tie(a):
        return round(a)
    return round_to_integral_toward_away(a)

# IEEE 754 命名
@assert_same_behavior_as(exact_wrapper_builtin_round)
def round_to_integral_ties_to_even(a: Rational) -> Rational:
    if not is_tie(a):
        return round(a)
    x, y = a + HALF, a - HALF
    return x if is_even(x) else y

def round_to_integral_ties_to_odd(a: Rational) -> Rational:
    if not is_tie(a):
        return round(a)
    x, y = a + HALF, a - HALF
    return x if is_odd(x) else y

# -------- 各种余数区间生成方式 --------

class FiniteRationalInterval(object):
    def __init__(self, left: Rational, right: Rational, left_close: bool, right_close: bool) -> None:
        if left >= right:
            raise ValueError('left must be less than right')
        self.left = left
        self.right = right
        self.left_close = left_close
        self.right_close = right_close

    def __str__(self) -> str:
        return "{}{}, {}{}".format(
            '[' if self.left_close else '(',
            self.left,
            self.right,
            ']' if self.right_close else ')'
        )

    def __contains__(self, item: Rational | FiniteRationalInterval) -> bool:
        if isinstance(item, rational_types_tuple):
            f1 = op.le if self.left_close else op.lt
            f2 = op.le if self.right_close else op.lt
            return f1(self.left, item) and f2(item, self.right)
        assert isinstance(item, FiniteRationalInterval)
        return (self.left < item.left or self.left == item.left and not (not self.left_close and item.left_close)) \
            and (item.right < self.right or item.right == self.right and not (not self.right_close and item.right_close))

    def is_half_open(self) -> bool:
        return self.left_close ^ self.right_close

def rem_interval_maker_nonnegative(n: Rational) -> FiniteRationalInterval:
    return FiniteRationalInterval(0, abs(n), True, False)

def rem_interval_maker_nonpositive(n: Rational) -> FiniteRationalInterval:
    return FiniteRationalInterval(-abs(n), 0, False, True)

def rem_interval_maker_0_left_close(n: Rational) -> FiniteRationalInterval:
    bound = abs(div_exact(n, 2))
    return FiniteRationalInterval(-bound, bound, True, False)

def rem_interval_maker_0_right_close(n: Rational) -> FiniteRationalInterval:
    bound = abs(div_exact(n, 2))
    return FiniteRationalInterval(-bound, bound, False, True)

# -------- 策略列举 --------

strat_plane = [
    [
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_toward_negative),
            '向下取整'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_toward_positive),
            '向上取整'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_toward_zero),
            '趋零截断'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_toward_away),
            '离零进位'),
    ],
    [
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_ties_to_negative),
            '约半向下'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_ties_to_positive),
            '约半向上'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_ties_to_zero),
            '约半趋零'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_ties_to_away),
            '约半离零'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_ties_to_even),
            '约半成偶'),
        DivModAlgorithm.from_div(
            make_div_from_rounding(round_to_integral_ties_to_odd),
            '约半成奇'),
    ],
    [
        DivModAlgorithm.from_mod(
            make_mod_from_interval_maker(rem_interval_maker_nonnegative),
            '余数非负'),
        DivModAlgorithm.from_mod(
            make_mod_from_interval_maker(rem_interval_maker_nonpositive),
            '余数非正'),
        DivModAlgorithm.from_mod(
            make_mod_from_interval_maker(rem_interval_maker_0_left_close),
            '约半左闭'),
        DivModAlgorithm.from_mod(
            make_mod_from_interval_maker(rem_interval_maker_0_right_close),
            '约半右闭'),
    ],
]

delegates: list[UnaryClosure[DivModAlgorithm]] = [
    identity,
    DivModAlgorithm.version_z,
    DivModAlgorithm.version_n,
    DivModAlgorithm.version_zn,
]

strat_cube_0_d_postfixs = [
    "", "_z", "_n", "_zn"
]

strat_cube: list[list[list[DivModAlgorithm]]] = [
    [
        [
            delegate(strat)
            for strat in strat_row
        ]
        for strat_row in strat_plane
    ]
    for delegate in delegates
]

all_strats: list[DivModAlgorithm] = [
    plane
    for plane in chain.from_iterable(
        chain.from_iterable(
            strat_cube
        )
    )
]

type QsAndRs = tuple[list[Rational], list[Rational]]

# -------- 和输出有关的计算 --------

def get_qs_and_rs(xs: list[Rational], n: Rational, strat: DivModAlgorithm) -> QsAndRs:
    qrs = [strat.divmod(x, n) for x in xs]
    return [q for q, _ in qrs], [r for _, r in qrs]

# -------- 策略等价行为研究 --------

type StrategyRepr = list[QsAndRs]

def key_maker(
        xs: list[Rational],
        ns: list[Rational],
        ) -> Callable[[DivModAlgorithm], StrategyRepr]:
    def key(strat: DivModAlgorithm) -> StrategyRepr:
        return [get_qs_and_rs(xs, n, strat) for n in ns]
    return key

def group_all() -> None:
    aa: list[tuple[str, list[Rational]]] = [
        ("-+", [div_exact(x, 4) for x in range(-16, 17) if x != 0]),
        ("-", [div_exact(x, 4) for x in range(-16, 1) if x != 0]),
        ("+", [div_exact(x, 4) for x in range(0, 17) if x != 0]),
    ]
    nn: list[tuple[str, list[Rational]]] = [
        ("-+", [1, -1]),
        ("-", [-1]),
        ("+", [1]),
    ]

    def get_group(key: Callable[[DivModAlgorithm], StrategyRepr]) -> list[list[str]]:
        return [[strat.name for strat in g] for _, g in groupby(sorted(all_strats, key=key), key=key)]

    def name_is_delegate(name: str) -> bool:
        return name[-1].isascii()

    def key_of_name(name: str) -> tuple[bool, str]:
        return (name_is_delegate(name), name)

    def key_of_name_list(names: list[str]) -> list[tuple[bool, str]]:
        return [key_of_name(name) for name in names]

    for (a_s, a), (n_s, n) in product(aa, nn):
        key_a_n = key_maker(a, n)
        groups = sorted(
            (
                sorted(g, key=key_of_name)
                for g in get_group(key_a_n)
            ),
            key=key_of_name_list,
        )
        print(f"-------- a({a_s}) n({n_s}) --------")
        for i, g in enumerate(groups):
            print( '{:>3d}. '.format(i)
                + ' '.join(
                    (lambda aligned:
                        aligned
                        if name_is_delegate(name)
                        else colored(aligned, 'yellow')
                    )("{:<7s}".format(name))
                    for name in g
                )
            )
        print(f"共 {len(groups)} 个等价类")

# -------- 绘图 --------

def draw() -> None:
    # 参数
    ns = [1, -1]  # 对所有策略画出 n=1 和 n=-1 的情况
    radius = 4
    denominator = 4
    assert denominator % 2 == 0
    dense_num = 2  # 要画的是直线不是曲线所以只有两个点就行

    # 数据及生成方式
    xs = [div_exact(x, denominator) for x in range(-radius * denominator, radius * denominator + 1)]
    xs_dense = np.linspace(float(xs[0]), float(xs[-1]), dense_num)

    # 绘图
    n_rows = len(ns)
    total_rows = n_rows * len(strat_plane)
    max_cols = max(len(row) for row in strat_plane)

    for delegate, postfix in zip(delegates, strat_cube_0_d_postfixs):
        fig, axes = plt.subplots(total_rows, max_cols, figsize=(max_cols * 3, total_rows * 3))
        for gi, strat_row in enumerate(strat_plane):
            n_cols = len(strat_row)
            for ri, n in enumerate(ns):
                arrayn = np.full(dense_num, n)
                for ci, strat in enumerate(strat_row):
                    ax = axes[gi * n_rows + ri, ci]
                    s = delegate(strat)
                    qs, rs = get_qs_and_rs(xs, n, s)
                    # 商指示线
                    ax.plot(xs_dense, xs_dense / n, c='r')
                    # 商范围
                    xs_dense_l = np.linspace(float(xs[0]), float(xs[-1]) - abs(n), dense_num)
                    xs_dense_r = np.linspace(float(xs[0]) + abs(n), float(xs[-1]), dense_num)
                    ax.plot(xs_dense_l, xs_dense_l / n + (1 if n >= 0 else -1), linestyle='--', c='r')
                    ax.plot(xs_dense_r, xs_dense_r / n + (1 if n <= 0 else -1), linestyle='--', c='r')
                    # 余数范围
                    ax.plot(xs_dense, arrayn, linestyle='--', c='g')
                    ax.plot(xs_dense, -arrayn, linestyle='--', c='g')
                    # 商
                    ax.scatter(xs, qs, c='r', s=10)
                    # 余数
                    ax.scatter(xs, rs, c='g', s=10)

                    ax.set_title(f'{s.name}(x, {n})')
                    ax.set_aspect('equal')
                    ax.grid(True)
                for ci in range(n_cols, max_cols):
                    axes[gi * n_rows + ri, ci].set_visible(False)
        fig.tight_layout()
        plt.savefig(f'divmod_plots{postfix}.png')

# -------- 主程序 --------

def main() -> None:
    sarasa_path = "C:\\Users\\ls_ho\\AppData\\Local\\Microsoft\\Windows\\Fonts\\SarasaFixedSC-Regular.ttf"
    fm.fontManager.addfont(sarasa_path)
    font_props = fm.FontProperties(fname=sarasa_path)
    sarasa_name = font_props.get_name()
    plt.rcParams['font.family']=[sarasa_name, 'sans-serif']
    #plt.rcParams['axes.unicode_minus'] = False
    draw()
    group_all()

if __name__ == '__main__':
    main()
