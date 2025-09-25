@testsnippet LicenseTestHelpers begin
  # Standard test package parameters
  test_pkg_name = "NewPkg.jl"
  test_owner = "JuliaBesties"
  test_authors = "JuliaBesties maintainers"

  # Helper function to create package with license and test LICENSE file
  function test_license_creation(license_value, should_exist; extra_kwargs...)
    _with_tmp_dir() do dir
      data = Dict("License" => license_value)
      BestieTemplate.new_pkg_quick(
        test_pkg_name,
        test_owner,
        test_authors,
        :tiny,
        data;
        extra_kwargs...,
      )

      license_path = joinpath(test_pkg_name, "LICENSE")
      if should_exist
        @test isfile(license_path)
      else
        @test !isfile(license_path)
      end
    end
  end
end

@testitem "Standard licenses create LICENSE file" tags = [:unit, :fast, :license_handling, :file_io] setup =
  [Common, LicenseTestHelpers] begin
  standard_licenses = ["Apache-2.0", "GPL-3.0", "MIT", "MPL-2.0"]

  for license in standard_licenses
    test_license_creation(license, true)
  end
end

@testitem "License 'nothing' does not create LICENSE file" tags =
  [:unit, :fast, :license_handling, :file_io] setup = [TestConstants, Common, LicenseTestHelpers] begin
  test_license_creation("nothing", false; template_source = :local, use_latest = true)
end
