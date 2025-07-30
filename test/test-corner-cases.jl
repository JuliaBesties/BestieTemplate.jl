@testitem "Test license creation for standard licenses" setup = [Common] begin
  for license in ("Apache-2.0", "GPL-3.0", "MIT", "MPL-2.0")
    _with_tmp_dir() do dir
      data = Dict("License" => license)
      BestieTemplate.new_pkg_quick(
        "NewPkg.jl",
        "JuliaBesties",
        "JuliaBesties maintainers",
        :tiny,
        data,
      )

      @test isfile(joinpath("NewPkg.jl", "LICENSE"))
    end
  end
end

@testitem "Test that license='nothing' does not create LICENSE file" setup = [Common] begin
  _with_tmp_dir() do dir
    data = Dict("License" => "nothing")
    BestieTemplate.new_pkg_quick(
      "NewPkg.jl",
      "JuliaBesties",
      "JuliaBesties maintainers",
      :tiny,
      data;
      template_source = :local,
      use_latest = true,
    )

    @test !isfile(joinpath("NewPkg.jl", "LICENSE"))
  end
end
