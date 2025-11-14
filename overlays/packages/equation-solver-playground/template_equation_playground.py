import marimo

__generated_with = "0.15.2"
app = marimo.App(width="medium")


@app.cell
def _():
    import sympy
    from sympy import symbols, Eq, solve

    return sympy, symbols, Eq, solve


@app.cell
def _(symbols, Eq, solve):
    # Define symbols
    x, y = symbols("x y")
    # Define an equation: x^2 = y
    equation = Eq(x**2, y)
    # Solve the equation for x
    solutions = solve(equation, x)
    print("Solving equation:", equation)
    print("Solutions for x:", solutions)
    return x, y, equation, solutions


if __name__ == "__main__":
    app.run()
