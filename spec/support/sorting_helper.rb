module SortingHelper
  def check_sorted_table(column_index, expected_order)
    rows = page.all("tbody tr")
    rows.each_with_index do |row, index|
      cells = row.all("td")
      targeted_cell = cells[column_index]
      expect(targeted_cell).to have_content(expected_order[index])
    end
  end

  def test_ordering_for(column_name:, column_index:, default_order:) # rubocop:disable Metrics/AbcSize
    check_sorted_table(column_index, default_order)

    find("[data-sort-by='#{column_name}']").click
    expect(page).to have_current_path(/sort_by=#{column_name}/)
    expect(page).to have_current_path(/sort_direction=asc/)
    check_sorted_table(column_index, default_order.sort)

    find("[data-sort-by='#{column_name}']").click
    expect(page).to have_current_path(/sort_by=#{column_name}/)
    expect(page).to have_current_path(/sort_direction=desc/)
    check_sorted_table(column_index, default_order.sort.reverse)

    find("[data-sort-by='#{column_name}']").click
    expect(page).to have_no_current_path(/sort_by/)
    check_sorted_table(column_index, default_order)
  end
end
