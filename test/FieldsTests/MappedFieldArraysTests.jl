module MappedFieldArraysTests

using Test
using Gridap.Arrays
using Gridap.Mappings
using Gridap.TensorValues
using Gridap.Mappings: evaluate
using Gridap.Mappings: test_mapped_array
using FillArrays
using Gridap.Helpers

using BenchmarkTools
using Test


np = 4
p1 = Point(1.0,2.0)
p2 = Point(2.0,1.0)
p3 = Point(4.0,3.0)
p4 = Point(6.0,1.0)

p = p1
# x = [p1,p2,p3,p4]

# fa = GenericField(x->2*x)
# fb = GenericField(x->Point(sqrt.(x.data)))

# c = return_cache(fa,x)
# @btime evaluate!(c,fa,x)

# c = return_cache(fb,x)
# @btime evaluate!(c,fb,x)

# aa = Fill(fa,4)
# r = apply(aa,x)
# @test all([ r[i] ≈ 2*x[i] for i in 1:4])

# c_r = array_cache(r)
# @btime getindex!($c_r,$r,1)

# bb = Fill(fb,4)
# r = apply(bb,x)
# @test all([ r[i] ≈ Point(sqrt.(x[i].data)) for i in 1:4])

# aaop = apply(operation,aa)
# cm = apply(aaop,bb)
# r = apply(cm,x)
# @test all([ r[i] ≈ 2*(Point(sqrt.(x[i].data))) for i in 1:4])

# c_r = array_cache(r)
# @btime getindex!($c_r,$r,1)

# aop = apply(Operation(+),aa,bb)
# apply(aa,x)+apply(bb,x)
# apply(evaluate,aop,x)
# @test apply(evaluate,aop,x) == apply(aa,x)+apply(bb,x)

# c_r = array_cache(r)
# @btime getindex!($c_r,$r,1)

# # BroadcastMapping and Operations

# ax = Fill(x,4)
# aa = Fill(fa,4)
# bb = Fill(fb,4)

# aop = apply(BroadcastMapping(Operation(+)),aa,bb)
# aax = apply(evaluate,aa,ax)
# bbx = apply(evaluate,bb,ax)
# aopx = apply(evaluate,aop,ax)
# @test aopx == aax+bbx

# c_r = array_cache(aopx)
# @btime getindex!($c_r,$aopx,1)

# aop = apply(BroadcastMapping(Operation(*)),aa,bb)
# aopx = apply(evaluate,aop,ax)
# @test aopx[1] == aax[1].*bbx[1]

# Allocations

# nf = 4
# np = 5
# na = 6

# _x = [p1,p2,p3,p4]

# x = rand(_x,np)
# ax = Fill(x,na)
# aa = Fill(Operation(fa),na)
# bb = Fill(fb,na)
# cm = apply(aa,bb)
# r = apply(cm,ax)

# for i in 1:na
#   for j in 1:np
#     @test r[i][j].data == 2.0.*sqrt.(ax[i][j].data)
#   end
# end

# c_r = array_cache(r)
# @btime getindex!($c_r,$r,1)

# Arrays of Arrays

np = 4
p1 = Point(1.0,2.0)
p2 = Point(2.0,1.0)
p3 = Point(4.0,3.0)
p4 = Point(6.0,1.0)

p = p1
np = 2
# x = [p1,p2,p3,p4]
x = [p1,p2]

f1 = GenericField(x->1*x)
f2 = GenericField(x->2*x)
f3 = GenericField(x->3*x)
f4 = GenericField(x->4*x)
f5 = GenericField(x->5*x)

h(x) = 2.0*x
f = GenericField(h)

q(x) = Point(sqrt.(x.data))
g = GenericField(q)

nf = 2
# basis = [f1, f2, f3, f4, f5]
basis = fill(f,nf)
field = g

na = 1

x_a = fill(x,na)
basis_a = fill(basis,na)
field_a = fill(field,na)

v = rand(nf)
v_a = fill(v,na)

vm = rand(nf,nf)
vm_a = fill(vm,na)

# Evaluate field
res_field_a = apply(field_a,x_a)

c_r = array_cache(res_field_a)
@btime getindex!($c_r,$res_field_a,1);

# Evaluate basis
res_basis_a = apply(basis_a,x_a)

c_r = array_cache(res_basis_a)
@btime getindex!($c_r,$res_basis_a,1);

cb = return_cache(basis,x)
@btime evaluate!(cb,basis,x)

# Transpose basis
tbasis_a = apply(transpose,basis_a)
@test all([ (tbasis_a[i] == transpose(basis_a[i])) for i in 1:na])

res_tbasis_a = apply(tbasis_a,x_a)
for j in 1:na
  @test all([res_tbasis_a[j][i,1,:] == res_basis_a[j][i,:] for i in 1:np])
end

c_r = array_cache(res_tbasis_a)
@btime getindex!($c_r,$res_tbasis_a,1);

# Broadcast operation basis basis
op = +
brbasis_a = apply(BroadcastMapping(Operation(op)),basis_a,basis_a)
res_brbasis_a = apply(evaluate,brbasis_a,x_a)

c_r = array_cache(res_brbasis_a)
@btime getindex!($c_r,$res_brbasis_a,$1);

# Broadcast operation basis field
op = +
brbasis_a = apply(BroadcastMapping(Operation(op)),basis_a,field_a)

res_brbasisfield_a = apply(evaluate,brbasis_a,x_a)
for j in 1:na
  for i in 1:np
    @test res_brbasisfield_a[j][i,:] == res_basis_a[j][i,:] .+ res_field_a[j][i]
  end
end

c_r = array_cache(res_brbasisfield_a)
@btime getindex!($c_r,$res_brbasisfield_a,1);

# Linear Combination basis values (vector values)
vxbasis_a = apply(linear_combination,basis_a,v_a)
res_vxbasis_a = apply(evaluate,vxbasis_a,x_a)

for j in 1:na
  for i in 1:np
    res_vxbasis_a[j][i] == transpose(res_basis_a[j][i,:])*v_a[j]
  end
end

c_r = array_cache(res_vxbasis_a)
@btime getindex!(c_r,res_vxbasis_a,1)

# Linear Combination basis values (matrix values)
vmxbasis_a = apply(linear_combination,basis_a,vm_a)
res_vmxbasis_a = apply(evaluate,vmxbasis_a,x_a)

for j in 1:na
  for i in 1:np
    res_vmxbasis_a[j][i] == transpose(res_basis_a[j][i,:])*vm_a[j]
  end
end

c_r = array_cache(res_vmxbasis_a)
@btime getindex!(c_r,res_vmxbasis_a,1)

# basis*transpose(basis)
basisxtbasis_a = apply(BroadcastMapping(Operation(⋅)),basis_a,tbasis_a)
res_basisxtbasis_a = apply(evaluate,basisxtbasis_a,x_a)
size(res_basisxtbasis_a[1])
for j in 1:na
  for i in 1:np
    @test res_basisxtbasis_a[j][i,:,:] == broadcast(⋅,res_basis_a[j][i,:],res_tbasis_a[j][i,:,:])
  end
end

c_r = array_cache(res_basisxtbasis_a)
@btime getindex!($c_r,$res_basisxtbasis_a,1);

# composition basis(field)
op = ∘
compfield_a = apply(op,field_a,field_a)

res_compfield_a = apply(evaluate,compfield_a,x_a)
@test all([ res_compfield_a[i] == apply(field_a,res_field_a)[i] for i in 1:na])

c_r = array_cache(res_compfield_a)
@btime getindex!($c_r,$res_compfield_a,1);

# composition basis(basis, field)
op = ∘
compbasisfield_a = apply(BroadcastMapping(op),basis_a,field_a)

res_compbasisfield_a = apply(evaluate,compbasisfield_a,x_a)
@test all([ res_compbasisfield_a[i] == apply(basis_a,res_field_a)[i] for i in 1:na])

c_r = array_cache(res_compbasisfield_a)
@btime getindex!($c_r,$res_compbasisfield_a,1);


# transpose(basis)*basis

# @santiagobadia : Do we want this syntax?
tbasisxbasis_a = apply(*,tbasis_a,basis_a)
res_tbasisxbasis_a = apply(evaluate,tbasisxbasis_a,x_a)
for j in 1:na
  for i in 1:np
    res_tbasisxbasis_a[j][i] == res_tbasis_a[j][i,1,:] ⋅ res_basis_a[j][i,:]
  end
end

c_r = array_cache(res_tbasisxbasis_a)
@btime getindex!($c_r,$res_tbasisxbasis_a,1);

# integration (field)

w_a = v_a
jac = GenericField(TensorValue(4.0,0.0,0.0,4.0))
jac_a = fill(jac,na)
res_jac_a = apply(evaluate,jac_a,x_a)

field_a
integrate_a = apply(integrate,field_a,w_a,jac_a,x_a)
res_integrate_a = apply(evaluate,integrate_a)

meas_a = apply(BroadcastMapping(meas),res_jac_a)
wmeas_a = apply(BroadcastMapping(*),w_a,meas_a)
for i in 1:length(x_a)
  @test transpose(res_field_a[i])*wmeas_a[i] == res_integrate_a[i]
end

c = array_cache(res_integrate_a)
@btime getindex!($c,$res_integrate_a,1)

# integration (basis)

w_a = v_a
jac = GenericField(TensorValue(4.0,0.0,0.0,4.0))
jac_a = fill(jac,na)
res_jac_a = apply(evaluate,jac_a,x_a)

integrate_a = apply(integrate,basis_a,w_a,jac_a,x_a)
res_integrate_a = apply(evaluate,integrate_a)

meas_a = apply(BroadcastMapping(meas),res_jac_a)
wmeas_a = apply(BroadcastMapping(*),w_a,meas_a)
for i in 1:length(x_a)
  @test transpose(res_basis_a[i])*wmeas_a[i] == res_integrate_a[i]
end

c = array_cache(res_integrate_a)
@btime getindex!(c,res_integrate_a,1)

end # module