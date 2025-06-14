#!/usr/bin/env node

console.log('Testing MCP server installation...');
console.log('Node version:', process.version);
console.log('Environment variables:');
console.log('  NODE_ENV:', process.env.NODE_ENV);
console.log('  PORT:', process.env.PORT);
console.log('  MCP_PORT:', process.env.MCP_PORT);
console.log('  PLAYWRIGHT_BROWSERS_PATH:', process.env.PLAYWRIGHT_BROWSERS_PATH);

// Check if @playwright/mcp is available
try {
  const { execSync } = require('child_process');
  
  console.log('\nChecking installed packages...');
  const npmList = execSync('npm list -g @playwright/mcp', { encoding: 'utf8' });
  console.log(npmList);
  
  console.log('\nChecking available commands...');
  try {
    const help = execSync('npx @playwright/mcp --help', { encoding: 'utf8', timeout: 5000 });
    console.log('npx @playwright/mcp --help output:');
    console.log(help);
  } catch (helpError) {
    console.log('Error running help command:', helpError.message);
  }
  
} catch (error) {
  console.error('Error checking MCP installation:', error.message);
}

console.log('\nTest completed.');
process.exit(0); 