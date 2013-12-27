package com.example.fingerdraw2;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;
import java.util.StringTokenizer;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.Environment;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

public class DrawView extends View implements OnTouchListener {
    private static final String TAG = "DrawView";

    List<Integer> newLine = new ArrayList<Integer>();

    private Canvas  mCanvas;
    private Path    mPath;
    private Paint   mPaint;   
    private int currentRGB;
    private Stack<Segment> segments = new Stack<Segment>();
    private Stack<Path> paths = new Stack<Path>();
    private ArrayList<Paint> paints = new ArrayList<Paint>();
    
    public DrawView(Context context, AttributeSet attrs) {
        super(context, attrs);
//        setWillNotDraw(false);
        setFocusable(true);
        setFocusableInTouchMode(true);
        setDrawingCacheEnabled(true);
        setOnTouchListener(this);

        init();        
    }

    private void init () {
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setDither(true);
        mPaint.setColor(Color.BLUE);
        mPaint.setStyle(Paint.Style.STROKE);
        mPaint.setStrokeJoin(Paint.Join.ROUND);
        mPaint.setStrokeCap(Paint.Cap.ROUND);
        mPaint.setStrokeWidth(6);
        mCanvas = new Canvas();
        mPath = new Path();
//        paths.push(mPath);

    	currentRGB = Color.argb(250, 0, 0, 0);

//        segments.add(new Segment(mPath,currentRGB));

//        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
//        paint.setStyle(Paint.Style.STROKE);
//        paint.setStrokeWidth(2);
//        paint.setColor(Color.BLUE);
        
        
//        paint.setAntiAlias(true);
//        paint.setStyle(Paint.Style.STROKE);
//        paint.setStrokeWidth(20);
    }
    
    public void setColor (String data) {
    	StringTokenizer tokens = new StringTokenizer(data, "|");
    	int red = Integer.parseInt(tokens.nextToken().trim());// this will contain "Fruit"
    	int green = Integer.parseInt(tokens.nextToken().trim());// this will contain "Fruit"
    	int blue = Integer.parseInt(tokens.nextToken().trim());// this will contain "Fruit"

    	currentRGB = Color.argb(200, red, green, blue);
    	//mPaint.setColor(Color.argb(200, red, green, blue) );
    }
    
    public boolean saveFile (String fileName) throws IOException {
    	Bitmap b = getDrawingCache();
    	
    	String fullFileName = Environment.getExternalStorageDirectory() + "/" + fileName + ".png";
    	OutputStream stream = new FileOutputStream(fullFileName);
    	/* Write bitmap to file using JPEG or PNG and 80% quality hint for JPEG. */
    	b.compress(CompressFormat.PNG, 80, stream);
    	stream.close();

    	return true;
    }
    
    public void clearScreen () {
    	segments.clear();
//    	paths.clear();
    	invalidate();
    }
    
    public void undo () {
//    	segments.remove(segments.size() - 1);
    	if (!segments.empty()) {
	    	segments.pop();
	    	invalidate();
    	}
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
    }

	@Override
    protected void onDraw(Canvas canvas) {    
    	System.out.println("On draw");
		super.onDraw(canvas);
    	for (Segment s : segments) {
    		mPaint.setColor(s.getColor());
    		canvas.drawPath(s.getPath(), mPaint);
    	}
//        for (Path p : paths){
//            canvas.drawPath(p, mPaint);
//        }
    }

    private float mX, mY;
    private static final float TOUCH_TOLERANCE = 4;

    private void touch_start(float x, float y)	 {
        mPath.reset();
        mPath.moveTo(x, y);
        mX = x;
        mY = y;
//        paths.push(mPath);
        segments.add(new Segment(mPath,currentRGB));
    }
    
    private void touch_move(float x, float y) {
//    	Path thisPath = paths.peek();
    	Path thisPath = segments.peek().getPath();
    	float dx = Math.abs(x - mX);
        float dy = Math.abs(y - mY);
        if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE) {
            thisPath.quadTo(mX, mY, (x + mX)/2, (y + mY)/2);
            mX = x;
            mY = y;
        }
        
//        Segment latestSegment = segments.get(segments.size() - 1);
//        latestSegment.segmentPath = mPath;
    }
    
    private void touch_up() {
    	System.out.println("Touch up");

//        mPath.lineTo(mX, mY);
        // commit the path to our offscreen
        mCanvas.drawPath(mPath, mPaint);
        // kill this so we don't double draw            
        
//        Segment latestSegment = segments.get(segments.size() - 1);
//        latestSegment.segmentPath = mPath;

//        segments.add(new Segment(mPath,currentRGB));
        mPath = new Path();
//        segments.add(new Segment(mPath,currentRGB));

//         paths.push(mPath);
       // paints.add(mPaint);
    }



	@Override
	public boolean onTouch(View arg0, MotionEvent event) {
	      float x = event.getX();
	      float y = event.getY();
	
	      switch (event.getAction()) {
	          case MotionEvent.ACTION_DOWN:
	              touch_start(x, y);
	              break;
	          case MotionEvent.ACTION_MOVE:
	              touch_move(x, y);
	              invalidate();
	              break;
	          case MotionEvent.ACTION_UP:
	              touch_up();
	              invalidate();
	              break;
	      }
	      return true;
	}

}

class Segment {
	Path segmentPath;
	int pathColor;
	
	public Segment (Path givenPath, int givenColor) {
		segmentPath = givenPath;
		pathColor = givenColor;
	}
	Path getPath () {
		return segmentPath;
	}
	int getColor() {
		return pathColor;
	}
}

