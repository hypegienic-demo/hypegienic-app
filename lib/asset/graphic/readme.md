# Generate dart canvas
Use https://github.com/aloisdeniel/built_vector/tree/master/built_vector to generate the canvas file

## To get started
You need to convert your standard svg file content into something like this first
```html
<assets name="icons">
  <vector name="warning" viewBox="0 0 24 24" fill="#231F20">
    <rect x="15" y="14" width="31" height="28" />
    <circle cx="45.5" cy="42.5" r="15.5" fill="#C4C4C4" />
    <path d="M12 17C12.5523 17 13 16.5523 13 16C13 15.4477 12.5523 15 12 15C11.4477 15 11 15.4477 11 16C11 16.5523 11.4477 17 12 17Z" />
  </vector>
</assets>
```

Then, run built_vector `pub global run built_vector -i <assets file path> -o <output dart file>`