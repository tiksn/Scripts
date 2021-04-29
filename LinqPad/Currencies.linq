<Query Kind="Expression">
  <Output>DataGrids</Output>
  <NuGetReference Prerelease="true">TIKSN-Framework</NuGetReference>
  <Namespace>System.Globalization</Namespace>
</Query>

CultureInfo.GetCultures(CultureTypes.AllCultures)
	.Where(x => !x.IsNeutralCulture && !x.Equals(CultureInfo.InvariantCulture))
	.Select(x => Tuple.Create(x, new RegionInfo(x.Name), 123.45.ToString("C", x)))
	.OrderBy(x => x.Item2.Name)