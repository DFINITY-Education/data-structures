import data_structures from 'ic:canisters/data_structures';

data_structures.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
