$content = Get-Content lib/my_belia_web/controllers/page_html/permohonan_geran.html.heex -Raw

# Replace submit button
$content = $content -replace '<%= submit "Seterusnya", class: "next-button" %>', '<.button type="submit" class="next-button">Seterusnya</.button>'

# Replace text_input functions
$content = $content -replace '<%= text_input f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="text" $2 />'

# Replace number_input functions  
$content = $content -replace '<%= number_input f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="number" $2 />'

# Replace email_input functions
$content = $content -replace '<%= email_input f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="email" $2 />'

# Replace telephone_input functions
$content = $content -replace '<%= telephone_input f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="tel" $2 />'

# Replace url_input functions
$content = $content -replace '<%= url_input f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="url" $2 />'

# Replace date_input functions
$content = $content -replace '<%= date_input f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="date" $2 />'

# Replace textarea functions
$content = $content -replace '<%= textarea f, :(\w+), ([^%]+) %>', '<.input field={f[:$1]} type="textarea" $2 />'

# Replace select functions (this is more complex)
$content = $content -replace '<%= select f, :(\w+),\s*\[([^\]]+)\],\s*([^%]+) %>', '<.input field={f[:$1]} type="select" $3>$2</.input>'

Set-Content lib/my_belia_web/controllers/page_html/permohonan_geran.html.heex $content
