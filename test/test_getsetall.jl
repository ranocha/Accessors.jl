module TestGetSetAll
using Test
using Accessors
using StaticNumbers
using StaticArrays


if VERSION >= v"1.6"  # for ComposedFunction
@testset "getall" begin
    obj = (a=1, b=2.0, c='3')
    @test (1,) === @inferred getall(obj, @optic _.a)
    @test (1, 2.0, '3') === @inferred getall(obj, @optic _ |> Properties())
    @test (1, 2.0, '3') === @inferred getall(obj, @optic _ |> Elements())
    @test (2, 3.0, '4') === @inferred getall(obj, @optic _ |> Elements() |> _ + 1)
    @test (1, 2.0) === @inferred getall(obj, @optic _ |> Elements() |> If(x -> x isa Number))
    @test (2.0,) === getall(obj, @optic _ |> Elements() |> If(x -> x isa Number && x >= 2))
    @test_broken (@inferred getall(obj, @optic _ |> Elements() |> If(x -> x isa Number && x >= 2)); true)
    @test_broken (@inferred getall(obj, @optic _ |> Elements() |> If(x -> x isa Number && x >= static(2))); true)

    obj = (a=1, b=((c=3, d=4), (c=5, d=6)))
    @test (3, 5) === @inferred getall(obj, @optic _.b |> Elements() |> _.c)
    @test (3, 4, 5, 6) === @inferred getall(obj, @optic _.b |> Elements() |> Properties())
    @test (9, 12, 15, 18) === @inferred getall(obj, @optic _.b |> Elements() |> Properties() |> Elements() |> _ * 3)

    obj = (a=((c=1, d=2),), b=((c=3, d=4), (c=5, d=6)))
    @test (1, 3, 5) === @inferred getall(obj, @optic _ |> Properties() |> Elements() |> _.c)
    f(obj) = getall(obj, @optic _ |> Properties() |> Elements() |> _[:c])
    @test (1, 3, 5) === @inferred f(obj)
    @test (1, 2, 3, 4, 5, 6) === @inferred getall(obj, @optic _ |> Properties() |> Elements() |> Properties())

    obj = ((a=((c=1, d=2),), b=((c=3, d=4), (c=5, d=6))),)
    @test (1, 2, 3, 4, 5, 6) === @inferred getall(obj, @optic _ |> Properties() |> Properties() |> Properties() |> Properties())
    @test (1, 2, 3, 4, 5, 6) === @inferred getall(obj, @optic _ |> Elements() |> Elements() |> Elements() |> Elements())
    @test (2, 5, 10, 17, 26, 37) === @inferred getall(obj, @optic _ |> Elements() |> Elements() |> Elements() |> Elements() |> _[1]^2 + 1)
    # maximal supported composition length of 10 optics:
    @test (2, 5, 10, 17, 26, 37) === @inferred getall(obj, @optic _ |> _[:] |> Elements() |> Elements() |> _[:] |> Elements() |> Elements() |> _[1]^2 + 1 |> only)

    # trickier types for Elements():
    obj = (a=("ab", "c"), b=([1 2; 3 4],), c=(SVector(1), SVector(2, 3)))
    @test ['b', 'c', 'd'] == @inferred getall(obj, @optic _.a |> Elements() |> Elements() |> _ + 1)
    @test [2, 4, 3, 5] == @inferred getall(obj, @optic _.b |> Elements() |> Elements() |> _ + 1)
    @test SVector(1, 2, 3) === @inferred getall(obj, @optic _.c |> Elements() |> Elements())
    @test [2, 3, 4] == @inferred getall(obj, @optic _.c |> Elements() |> Elements() |> _ + 1)
    @test_broken SVector(2, 3, 4) === getall(obj, @optic _.c |> Elements() |> Elements() |> _ + 1)

    obj = ()
    @test () === @inferred getall(obj, @optic _ |> Elements() |> _ + 1)
    obj = (1,)
    @test (2,) === @inferred getall(obj, @optic _ |> Elements() |> _ + 1)
    obj = Int[]
    @test Int[] == @inferred getall(obj, @optic _ |> Elements() |> _ + 1)
    obj = [1]
    @test [2] == @inferred getall(obj, @optic _ |> Elements() |> _ + 1)

    obj = [1, 2, 3]
    @test [3] == getall(obj, @optic _ |> Elements() |> If(>(2)))
    @test_broken (@inferred getall(obj, @optic _ |> Elements() |> If(>(2))); true)
    obj = ([1, 2], 3:5, (6,))
    @test [1, 2, 3, 4, 5, 6] == @inferred getall(obj, @optic _ |> Elements() |> Elements())
    @test [2, 3, 4, 5, 6, 7] == @inferred getall(obj, @optic _ |> Elements() |> Elements() |> _ + 1)
    obj = [[1, 2], [3]]
    @test [1, 2, 3] == @inferred getall(obj, @optic _ |> Elements() |> Elements())

    obj = ([1, 2], [:a, :b])
    @test [1, 2, :a, :b] == @inferred getall(obj, @optic _ |> Elements() |> Elements())
end
end

end
