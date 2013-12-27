package com.example.fingerdraw2;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Set;
import java.util.UUID;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class MainActivity extends Activity {
	DrawView drawView;
	
    String myLabel;
    EditText myTextbox;
    BluetoothAdapter mBluetoothAdapter;
    BluetoothSocket mmSocket;
    BluetoothDevice mmDevice;
    OutputStream mmOutputStream;
    InputStream mmInputStream;
    Thread workerThread;
    byte[] readBuffer;
    int readBufferPosition;
    int counter;
    volatile boolean stopWorker;
    
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        Button openButton = (Button)findViewById(R.id.open);
        Button sendButton = (Button)findViewById(R.id.send);
        Button closeButton = (Button)findViewById(R.id.close);
        drawView = (DrawView)findViewById(R.id.canvas);
        //Open Button
        openButton.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                try 
                {
                    findBT();
                    openBT();
                }
                catch (IOException ex) { }
            }
        });
        
        //Send Button
        sendButton.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                try 
                {
                    requestData();
                }
                catch (IOException ex) { }
            }
        });
        
        //Close button
        closeButton.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                try 
                {
                    closeBT();
                }
                catch (IOException ex) { }
            }
        });

       // drawView = new DrawView(this);
       // setContentView(drawView);
       // drawView.requestFocus();

	}

	@Override
	  public boolean onCreateOptionsMenu(Menu menu) {
	    MenuInflater inflater = getMenuInflater();
	    inflater.inflate(R.menu.main, menu);
	    return true;
	  } 
	
	    @SuppressLint("NewApi")
		@Override
	    public boolean onOptionsItemSelected(MenuItem item) {
//			return true;
	        // Take appropriate action for each action item click
	        switch (item.getItemId()) {
	        case R.id.action_new:
	        	drawView.clearScreen();
	        	return true;
	        case R.id.action_save:
	        	final EditText input = new EditText(this);
	        	new AlertDialog.Builder(MainActivity.this)
	            .setTitle("Save existing file?")
	            .setMessage("Enter file name:")
	            .setView(input)
				.setCancelable(true)
	            .setPositiveButton("Save", new DialogInterface.OnClickListener() {
	                public void onClick(DialogInterface dialog, int whichButton) {
	                    Editable value = input.getText();
	    	        	try {
	    					drawView.saveFile(value.toString());
	    				} catch (IOException e) {
	    					// TODO Auto-generated catch block
	    					e.printStackTrace();
	    				}	        		                    
	                }
	            }).setNegativeButton("Don't Save", new DialogInterface.OnClickListener() {
	                public void onClick(DialogInterface dialog, int whichButton) {
	                    // Do nothing.
	                }
	            }).show();
	        	
	            return true;
	            
	            
	        case R.id.action_undo:
//	            // location found
	            drawView.undo();
	            return true;
	        case R.id.action_bluetooth:
	        	findBT();
		        if(mBluetoothAdapter == null) {
		        	return true;
		        }
		        try {
					openBT();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		        
	        	boolean connected = mmSocket.isConnected();
				if (connected) {
	        		item.setIcon(getResources().getDrawable(R.drawable.ic_action_bluetooth_connected));
	        	}
	        	else { 
	        		item.setIcon(getResources().getDrawable(R.drawable.ic_action_bluetooth));
	        	}
	            return true;

//	        case R.id.action_refresh:
//	            // refresh
//	            return true;
//	        case R.id.action_help:
//	            // help action
//	            return true;
//	        case R.id.action_check_updates:
//	            // check for updates action
//	            return true;
	        default:
	            return super.onOptionsItemSelected(item);
	        }
	    }


	void displayToast (String message) {
        Toast.makeText(getBaseContext(), message, 
     		   Toast.LENGTH_LONG).show();
	}
	
	 void findBT() {
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if(mBluetoothAdapter == null)
        {
        	displayToast("No bluetooth adapter available");
            myLabel = "No bluetooth adapter available";
            return;
        }
        
        if(!mBluetoothAdapter.isEnabled())
        {
            Intent enableBluetooth = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBluetooth, 0);
        }
        
        Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
        if(pairedDevices.size() > 0)
        {
            for(BluetoothDevice device : pairedDevices)
            {
                if(device.getName().equals("HC-05")) 
                {
                    mmDevice = device;
                    break;
                }
            }
        }
        myLabel = "Bluetooth Device Found";
        displayToast("Paired Device Found");
    }
	 
	 
	    void openBT() throws IOException
	    {
	        UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb"); //Standard SerialPortService ID
	        mmSocket = mmDevice.createRfcommSocketToServiceRecord(uuid);        
	        
	        try {
	        	mmSocket.connect();
		        mmOutputStream = mmSocket.getOutputStream();
		        mmInputStream = mmSocket.getInputStream();
		        myLabel = "Bluetooth Opened";
		        displayToast("Bluetooth Connected");
		        
		        beginListenForData();
            } 
	        catch (IOException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
                displayToast("Device not found");
            }
	        	        
	    }
	    
	    void beginListenForData()
	    {
	        final Handler handler = new Handler(); 
	        final byte delimiter = 10; //This is the ASCII code for a newline character
	        
	        stopWorker = false;
	        readBufferPosition = 0;
	        readBuffer = new byte[1024];
	        workerThread = new Thread(new Runnable()
	        {
	            public void run()
	            {                
	               while(!Thread.currentThread().isInterrupted() && !stopWorker)
	               {
	                    try 
	                    {
	                        int bytesAvailable = mmInputStream.available();                        
	                        if(bytesAvailable > 0)
	                        {
	                            byte[] packetBytes = new byte[bytesAvailable];
	                            mmInputStream.read(packetBytes);
	                            for(int i=0;i<bytesAvailable;i++)
	                            {
	                                byte b = packetBytes[i];
	                                if(b == delimiter)
	                                {
	                                    byte[] encodedBytes = new byte[readBufferPosition];
	                                    System.arraycopy(readBuffer, 0, encodedBytes, 0, encodedBytes.length);
	                                    final String data = new String(encodedBytes, "US-ASCII");
	                                    readBufferPosition = 0;
	                                    
	                                    handler.post(new Runnable()
	                                    {
	                                        public void run()
	                                        {
	                                            myLabel = data;
	                                            drawView.setColor(data);
	                                            displayToast(data);
	                                        }
	                                    });
	                                }
	                                else
	                                {
	                                    readBuffer[readBufferPosition++] = b;
	                                }
	                            }
	                        }
	                    } 
	                    catch (IOException ex) 
	                    {
	                        stopWorker = true;
	                    }
	               }
	            }
	        });

	        workerThread.start();
	    }
	    
	    void requestData() throws IOException
	    {
	        //String msg = myTextbox.getText().toString();
	        String msg = "c\n";
	    	//msg += "\n";
	        mmOutputStream.write(msg.getBytes());
	        myLabel = "Data requested";
	        displayToast("Data requested");
	    }
	    
	    void closeBT() throws IOException
	    {
	        stopWorker = true;
	        mmOutputStream.close();
	        mmInputStream.close();
	        mmSocket.close();
	        myLabel = "Bluetooth Closed";
	        displayToast("BLuetooth Closed");
	    }
}
