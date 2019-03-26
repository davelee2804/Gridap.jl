
@time @testset "OtherCellArrays" begin 

  aa = [1.0,2.0,2.1]
  l = 10
  a = Numa.OtherConstantCellArray(aa,l)

  @testset "OtherConstantCellArray" begin

    @test length(a) == l
    @test maxsize(a) == size(aa)
    @test maxsize(a,1) == size(aa,1)
    @test eltype(a) == Array{Float64,1}
    @test maxlength(a) == length(aa)
    for ar in a
      @assert ar == aa
    end
    s = string(a)
    s0 = """
    1 -> [1.0, 2.0, 2.1]
    2 -> [1.0, 2.0, 2.1]
    3 -> [1.0, 2.0, 2.1]
    4 -> [1.0, 2.0, 2.1]
    5 -> [1.0, 2.0, 2.1]
    6 -> [1.0, 2.0, 2.1]
    7 -> [1.0, 2.0, 2.1]
    8 -> [1.0, 2.0, 2.1]
    9 -> [1.0, 2.0, 2.1]
    10 -> [1.0, 2.0, 2.1]
    """
    @test s == s0

  end

  @testset "OtherCellArrayFromUnaryOp" begin

    eval(quote

      struct DummyCellArray <: Numa.OtherCellArrayFromUnaryOp{Float64,2}
        a::Numa.OtherCellArray{Float64,1}
      end
      
      Numa.inputcellarray(self::DummyCellArray) = self.a
      
      Numa.computesize(self::DummyCellArray,asize) = (2,asize[1])
      
      function Numa.computevals!(self::DummyCellArray,a,v)
        @inbounds for i in 1:size(a,1)
          v[1,i] = a[i]
          v[2,i] = a[i]
        end
      end

    end)

    bb = [aa';aa']
    b = DummyCellArray(a)

    @test inputcellarray(b) === a
    @test length(b) == l
    @test maxsize(b) == (2,size(aa,1))
    @test maxsize(b,1) == 2
    @test maxsize(b,2) == size(aa,1)
    @test eltype(b) == Array{Float64,2}
    @test maxlength(b) == 2*length(aa)
    for br in b
      @assert br == bb
    end

  end

  #cs(asize) = (2,asize[1])

  #function cv!(avals,asize,vals,s)
  #  @inbounds for i in 1:asize[1]
  #    vals[1,i] = avals[i]
  #    vals[2,i] = avals[i]
  #  end
  #end

  #b = Numa.OtherCellArrayFromUnaryOp{Float64,1,Float64,2}(a,cv!,cs)

  #bb = [aa';aa']

  #@test length(b) == l
  #@test maxsize(b) == size(bb)

  #for (br,s) in b
  #  @assert s == size(br)
  #  @assert br == bb
  #end

  #c = Numa.DummyCellArray(a)

  #@test length(c) == l
  #@test maxsize(c) == size(bb)

  #for (br,s) in c
  #  @assert s == size(br)
  #  @assert br == bb
  #end

end